#!/usr/bin/env python3
"""Query static/declared NREC infrastructure config in the himlar repo (Puppet + Hiera).

Read-only. Resolves the repo root from its own location (repo/skills/himlar-inventory/scripts/),
so it works from any clone location and any agent harness.

Requires: python3 + PyYAML.
"""
import argparse
import json
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit(
        "ERROR: PyYAML is required. Run with an interpreter that has it "
        "(e.g. himlarcli's venv: source bin/activate) or: pip install pyyaml"
    )

REPO = Path(__file__).resolve().parents[3]
HD = REPO / "hieradata"


def emit(data, as_json):
    if as_json:
        print(json.dumps(data, indent=2, default=str))
    else:
        print(yaml.safe_dump(data, sort_keys=False, default_flow_style=False, width=120))


def load(path):
    """Load a YAML file; parse errors become an in-band marker, never a crash."""
    try:
        with open(path) as fh:
            data = yaml.safe_load(fh)
        return data if isinstance(data, dict) else {}
    except Exception as exc:  # noqa: BLE001 - report, don't crash
        return {"__parse_error__": str(exc)}


def locations():
    return sorted(
        d.name for d in HD.iterdir()
        if d.is_dir() and d.name not in ("nodes", "common") and not d.name.startswith("secrets")
    )


def guess_location(host):
    host = host.split(".")[0]
    locs = locations() + ["common"]
    for loc in sorted(locs, key=len, reverse=True):
        if host.startswith(loc + "-"):
            return loc
    return None


def guess_role(host, loc):
    """osl-compute-shpc-011 -> compute-shpc ; osl-login-01old -> login."""
    stem = host.split(".")[0]
    if loc and stem.startswith(loc + "-"):
        stem = stem[len(loc) + 1:]
    m = re.match(r"^(.*?)-\d{1,3}[a-z]*(?:[-_]?\w*)?$", stem)
    role = m.group(1) if m and m.group(1) else stem
    return role


def node_files(loc):
    d = HD / "nodes" / loc
    return sorted(d.glob("*.yaml")) if d.is_dir() else []


def yaml_files(glob="*.yaml"):
    return sorted(HD.rglob(glob))


def flatten(data, prefix="", depth=0, max_depth=2):
    out = {}
    if not isinstance(data, dict):
        return out
    for k, v in data.items():
        key = f"{prefix}{k}"
        if isinstance(v, dict) and depth < max_depth:
            out.update(flatten(v, prefix=f"{key}/", depth=depth + 1, max_depth=max_depth))
        else:
            s = (yaml.safe_dump(v, default_flow_style=True).strip() if not isinstance(v, str) else v).strip()
            out[key] = s[:120] + ("..." if len(s) > 120 else "")
    return out


def walk_scalars(data, path=""):
    """Yield (key_path, scalar_value_str) for every scalar in a nested structure."""
    if isinstance(data, dict):
        for k, v in data.items():
            yield from walk_scalars(v, f"{path}/{k}" if path else str(k))
    elif isinstance(data, list):
        for i, v in enumerate(data):
            yield from walk_scalars(v, f"{path}[{i}]")
    else:
        yield path, str(data)


def cmd_locations(args):
    locs = locations()
    emit({"locations": locs, "node_counts": {l: len(node_files(l)) for l in locs}}, args.json)


def cmd_roles(args):
    out = {}
    for loc in ([args.location] if args.location else locations() + ["common"]):
        d = HD / loc / "roles"
        if d.is_dir():
            out[loc] = sorted(p.stem for p in d.glob("*.yaml"))
    emit(out, args.json)


def cmd_nodes(args):
    locs = [args.location] if args.location else locations()
    out = {}
    for loc in locs:
        rows = []
        for f in node_files(loc):
            host = f.stem
            role = guess_role(host, loc)
            if args.role and args.role not in role:
                continue
            rows.append({"host": host, "role": role})
        out[loc] = rows
    emit(out, args.json)


def hierarchy_files(host):
    """Return himlar's hiera v5 hierarchy (highest priority first) that applies to host."""
    loc = args_location or guess_location(host)
    role = guess_role(host, loc) if host else None
    variant = None  # role-variant files (e.g. compute-shpc) are matched by the base role name here
    files = []
    if host and loc:
        files.append(HD / "nodes" / loc / f"{host.split('.')[0]}.yaml")
    if loc:
        files += sorted((HD / loc / "platform").glob("*.yaml")) if (HD / loc / "platform").is_dir() else []
        if role:
            for name in ([f"{role}-{variant}", role] if variant else [role]):
                files.append(HD / loc / "roles" / f"{name}.yaml")
        files += sorted((HD / loc / "modules").glob("*.yaml")) if (HD / loc / "modules").is_dir() else []
        files.append(HD / loc / "common.yaml")
    files += sorted((HD / "common" / "platform").glob("*.yaml")) if (HD / "common" / "platform").is_dir() else []
    if role:
        files.append(HD / "common" / "roles" / f"{role}.yaml")
    files += sorted((HD / "common" / "modules").glob("*.yaml")) if (HD / "common" / "modules").is_dir() else []
    files.append(HD / "common" / "common.yaml")
    return [f for f in files if f.is_file()]


def cmd_node(args):
    global args_location
    files = hierarchy_files(args.host)
    out = {"host": args.host, "location": guess_location(args.host),
           "role": guess_role(args.host, guess_location(args.host))}
    levels = []
    for f in files:
        data = load(f)
        if not data:
            continue
        if args.full:
            levels.append({"file": str(f.relative_to(REPO)), "data": data})
        else:
            levels.append({"file": str(f.relative_to(REPO)), "keys": flatten(data)})
    out["hierarchy"] = levels
    emit(out, args.json)


def cmd_network(args):
    loc = args.location
    f = HD / loc / "common.yaml"
    data = load(f)
    netcfg = {k: v for k, v in data.items()
              if re.search(r"netcfg_|bgp|gateway|vlan|network", str(k), re.I) and "dns" not in k.lower()}
    out = {"location": loc, "location_network": netcfg}
    if args.host:
        nf = HD / "nodes" / loc / f"{args.host.split('.')[0]}.yaml"
        nd = load(nf)
        out["host_network"] = {
            k: v for k, v in nd.items()
            if re.search(r"named_interfaces|network|bond|interface|mtu|bmc|ipmi", str(k), re.I)
        }
    emit(out, args.json)


def cmd_dns(args):
    out = {}
    for f in [HD / args.location / "common.yaml", HD / "common" / "common.yaml"]:
        data = load(f)
        hits = {k: v for k, v in data.items() if "dns" in str(k).lower()}
        if hits:
            out[str(f.relative_to(REPO))] = hits
    emit(out, args.json)


def cmd_nova_config(args):
    pat = re.compile(args.key or "nova")
    host = args.host
    out = []
    for f in hierarchy_files(host):
        data = load(f)
        hits = {k: v for k, v in data.items() if pat.search(str(k))}
        if hits:
            out.append({"file": str(f.relative_to(REPO)), "keys": flatten(hits, max_depth=3)})
    emit({"host": host or "(no host: role files skipped)", "nova_keys": out}, args.json)


def cmd_mdev(args):
    out = []
    roots = [HD / args.location / "roles", HD / "common" / "roles"] if args.location \
        else [HD]
    for root in roots:
        for f in sorted(root.rglob("*.yaml")) if root.is_dir() else []:
            data = load(f)
            hits = {k: v for k, v in data.items() if "mdev" in str(k).lower() or "sriov" in str(k).lower()}
            if hits:
                out.append({"file": str(f.relative_to(REPO)), "keys": hits})
    emit(out, args.json)


def cmd_search(args):
    pat = re.compile(args.pattern, re.I)
    hits = []
    for f in yaml_files(args.glob):
        data = load(f)
        for key, val in walk_scalars(data):
            if pat.search(key) or pat.search(val):
                hits.append({"file": str(f.relative_to(REPO)), "key": key, "value": val[:100]})
                if len(hits) >= args.limit:
                    break
        if len(hits) >= args.limit:
            break
    emit({"pattern": args.pattern, "count": len(hits), "hits": hits}, args.json)


def main():
    global args_location
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", help="override repo root (default: derived from script location)")
    ap.add_argument("--json", action="store_true", help="machine-readable JSON output")
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("locations", help="list hieradata locations and node counts")
    p = sub.add_parser("roles", help="list role files per location")
    p.add_argument("--location")
    p = sub.add_parser("nodes", help="node inventory per location")
    p.add_argument("--location")
    p.add_argument("--role", help="substring filter on inferred role")
    p = sub.add_parser("node", help="merged-hierarchy view of one node's config")
    p.add_argument("host")
    p.add_argument("--full", action="store_true", help="raw YAML per level instead of flattened keys")
    p = sub.add_parser("network", help="netcfg/BGP for a location, plus host interfaces with --host")
    p.add_argument("--location", required=True)
    p.add_argument("--host")
    p = sub.add_parser("dns", help="dns_records for a location")
    p.add_argument("--location", required=True)
    p = sub.add_parser("nova-config", help="nova-related hiera keys along a host's hierarchy")
    p.add_argument("--host", help="e.g. osl-compute-shpc-011")
    p.add_argument("--key", help="regex filter on key (default: 'nova')")
    p = sub.add_parser("mdev", help="vGPU mdev/sriov config in role files")
    p.add_argument("--location")
    p = sub.add_parser("search", help="regex search over all hieradata keys+values")
    p.add_argument("pattern")
    p.add_argument("--glob", default="*.yaml")
    p.add_argument("--limit", type=int, default=50)

    args = ap.parse_args()
    if args.repo:
        global REPO, HD
        REPO = Path(args.repo).resolve()
        HD = REPO / "hieradata"
    args_location = getattr(args, "location", None)
    if not HD.is_dir():
        sys.exit(f"ERROR: no hieradata/ under {REPO}. Run from inside a himlar clone "
                 "or pass --repo /path/to/himlar")
    {"locations": cmd_locations, "roles": cmd_roles, "nodes": cmd_nodes, "node": cmd_node,
     "network": cmd_network, "dns": cmd_dns, "nova-config": cmd_nova_config,
     "mdev": cmd_mdev, "search": cmd_search}[args.cmd](args)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:  # output piped through head/less by a harness
        sys.exit(0)
