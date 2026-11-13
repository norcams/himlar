---
name: himlar-inventory
description: Query static/declared NREC cloud infrastructure from the himlar Puppet repo - host inventory, roles, network/netcfg/BGP, DNS records, nova config along the hiera hierarchy, vGPU mdev config, and key search. Read-only, no live cloud access. Use when asked who/what is declared, where a setting lives in hiera, or which hosts/roles exist.
compatibility: Requires python3 with PyYAML (system python or any venv with pyyaml). No network, no credentials, reads YAML only. Repo root is resolved from the script location; pass --repo to override.
license: Apache-2.0
metadata:
  author: NREC
  version: "1.0"
---

# himlar inventory

Answer questions about the *declared* state of the NREC cloud from the himlar
repo alone (Puppet + Hiera). Never contacts a live cloud — for dynamic state
use himlarcli scripts instead.

All queries go through one script (run from anywhere):

```bash
python3 skills/himlar-inventory/scripts/himlar_query.py <subcommand> [options]
```

Add `--json` to any subcommand for machine-readable output; `--repo PATH` to
point at another clone.

## Subcommands

- `locations` — hieradata locations (regions) and node-file counts per location
- `roles [--location L]` — role files per location (compute-shpc, storage, leaf, ...)
- `nodes [--location L] [--role SUBSTR]` — node inventory; role is inferred
  from the hostname convention `<loc>-<role>-<id>`
- `node <host> [--full]` — the node's hiera hierarchy in resolution order
  (nodes → loc/platform → loc/roles → loc/modules → loc/common → common/*),
  flattened keys per level; `--full` for raw YAML
- `network --location L [--host H]` — netcfg_*/bgp/gateway keys from
  `<loc>/common.yaml`; with `--host` also named_interfaces, bonding, MTU, BMC
- `dns --location L` — dns_records service entries
- `nova-config [--host H] [--key REGEX]` — every nova-related hiera key along a
  host's hierarchy with its source file; catches the two-mechanism duplicate
  pitfall (`nova::config::nova_config` vs `profile::openstack::*::default_nova_config`)
- `mdev [--location L]` — vGPU mdev_types / sriov declarations in role files
- `search <REGEX> [--limit N]` — regex over all hieradata keys and scalar
  values; the escape hatch for anything the fixed subcommands don't cover

## Examples

```bash
Q=skills/himlar-inventory/scripts/himlar_query.py
python3 $Q nodes --location osl --role shpc      # which shpc compute hosts exist
python3 $Q node osl-compute-shpc-011             # what applies to this host, in hiera order
python3 $Q network --location osl                # mgmt/trp subnets, gateways, BGP AS
python3 $Q nova-config --host osl-novactrl-01 --key quota   # quota settings + source
python3 $Q mdev --location osl                   # L40S vGPU mdev types + PCI addrs
python3 $Q search 'count_usage_from_placement'   # where is this key set?
```

## Interpretation notes

- Hiera is first-match-wins per key unless the consuming class deep-merges;
  `node`/`nova-config` show all levels with sources — the topmost level that
  defines a key is what puppet-nova plain-hiera keys resolve to, while
  `default_nova_config` hashes merge across levels.
- `secrets/` is not in this repo; secrets cannot be queried here by design.
- Production roles come from Foreman; role inference here is the naming
  convention, which matches by construction.
