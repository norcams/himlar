# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`himlar` is the Puppet control repository for NREC / UH-IaaS — an OpenStack installation
run at multiple physical locations (`bgo`, `osl`, plus test/dev locations). It is
**masterless Puppet**: every node runs `puppet apply` locally against a checkout of this
repo at `/opt/himlar`. There is no Puppet master, no ENC, and no `node {}` definitions —
`manifests/site.pp` classifies each node purely from its certname plus Hiera lookups.

## Commands

```bash
bundle install                 # deps (rake, puppet, puppet-syntax, puppet-lint)
bundle exec rake test          # syntax + lint — this is what CI runs
bundle exec rake syntax        # Puppet manifests, templates, and hieradata YAML
bundle exec rake lint          # puppet-lint (fail_on_warnings = true)
```

There is no spec/unit test suite; `rake test` is syntax + style only. Lint config lives in
`Rakefile` — 80/140-char, arrow alignment, documentation, and double-quoted-string checks
are deliberately disabled.

### Local development with Vagrant

```bash
vagrant up <node>                        # e.g. vagrant up identity, vagrant up compute-01
./provision/vagrant-allup.sh             # bring up every node in nodes.yaml, in order, with logs
./provision/vagrant-provision.sh <node>  # rsync + re-provision one node, logs to /tmp/himlar-$USER
HIMLAR_NODESET=<name> vagrant up         # select a nodeset from nodes.yaml
```

`nodes.yaml` defines `defaults`, `networks`, and named `nodesets`. Override locally with
`nodes.yaml.local` (gitignored, deep-merged per top-level section). The repo is rsynced to
`/opt/himlar` in the guest — **not** a shared folder, so `vagrant rsync` (or the helper
script) is required after editing files.

`vagrant-allup.sh` and `get_vagrant_nodes.pl` need perl `Readonly` and `YAML::XS`.

### Provisioning chain

Vagrant runs three scripts in order, passing every `HIMLAR_*` / `FACTER_*` env var as args:

1. `provision/puppetbootstrap.sh` — configures NREC yum repos and installs the puppet agent.
2. `provision/puppetmodules.sh` — symlinks `manifests/`, `hieradata/`, `hiera.yaml` into
   `/etc/puppetlabs/code/environments/$PUPPET_ENV`, runs `r10k` for `Puppetfile` (into
   `code/modules`) and for `puppetfiles/$PUPPET_ENV.Puppetfile` (into the environment's
   `modules`), then symlinks `profile/` in. Modules are only re-deployed when the target
   dir is empty or `HIMLAR_DEPLOYMENT=redeploy`.
3. `provision/puppetrun.sh` — `puppet apply` on `site.pp` with `--certname`,
   `--environment`, the repo `hiera.yaml`, and a basemodulepath of
   `/opt/himlar/modules:<env>/modules:code/modules`. If `/opt/himlar/bootstrap` exists it
   first does a `FACTER_RUNMODE=bootstrap` run and removes the marker on success.

Extra args are passed straight through to `puppet apply`, so on a node you can do e.g.
`provision/puppetrun.sh --noop`.

## Architecture

### Certname drives everything

`manifests/site.pp` splits `$trusted['certname']` on `-` to derive the facts the whole
Hiera hierarchy keys off:

```
<location>-<role>[-<variant>]-<hostid>.<domain>
bgo-compute-007.mgmt.bgo.uhdc.no        -> location=bgo role=compute            hostid=007
osl-compute-shpc-055.mgmt.osl.uhdc.no   -> location=osl role=compute variant=shpc hostid=055
```

A 4-part hostname yields a `variant`; a 3-part one leaves `$variant` empty. `site.pp` also
sets `$os_platform`/`$os_version` (`el9`, `debian11`, `opx3`), derives BMC addresses from
`ipaddress_mgmt1` on physical nodes, and defaults `$runmode`.

**Renaming a node changes its classification.** Adding a variant to a hostname moves it to
a different role file and a different node file.

### Classification via `include` + runmode

Node classification is data, not code. `site.pp` ends with:

```puppet
$runmode_classes = lookup("include.${::runmode}", Array, 'deep', [])
$runmode_classes.include
```

Every YAML level may contribute a list of profile classes under `include:`, keyed by
runmode. The `deep` merge means role, location, platform, and node files **accumulate**
classes rather than override — there is no way to remove a class added at a higher level
from a lower one. Every other Hiera key uses default first-found priority.

Runmodes: `default` (normal runs), `kickstart` (Foreman install-time, `is_installer` fact),
`bootstrap` (first run before the rest of the infrastructure exists).

### Hiera hierarchy (`hiera.yaml`)

Highest to lowest priority:

1. `secrets/nodes/<host>.secrets.yaml`, `secrets/<location>-common.secrets.yaml`
2. `nodes/<location>/<host>.yaml`
3. `<location>/platform/<os_platform><os_version>.yaml`, then `<os_platform>.yaml`
4. `<location>/roles/<role>-<variant>.yaml`, then `<role>.yaml`
5. `<location>/modules/*.yaml` (glob)
6. `<location>/common.yaml`
7. `common/platform/…`, `common/roles/…`, `common/modules/*.yaml`, `common/common.yaml`

`hieradata/secrets/` is gitignored — it comes from a separate private repo, deployed by
`provision/puppetsecrets.sh`. Expect lookups against keys with no visible definition here.

Where to put a change:

- one machine → `hieradata/nodes/<location>/<host>.yaml`
- a class of machines at one site → `hieradata/<location>/roles/<role>[-<variant>].yaml`
- everywhere → `hieradata/common/roles/…` or `hieradata/common/modules/<module>.yaml`

`common/modules/*.yaml` files are named after the upstream Puppet module they parameterise
(`nova.yaml`, `ceph.yaml`, `haproxy.yaml`) and hold that module's class parameters.

### The `profile` module

`profile/` is the only Puppet code in this repo (~212 manifests). Everything a node
includes is a `profile::*` class; upstream modules are never included directly from
Hiera's `include` lists. Namespaces mirror the directory layout:
`profile::openstack::compute::hypervisor` → `profile/manifests/openstack/compute/hypervisor.pp`.

Conventions in profile classes:

- Class parameters get their values from Hiera automatic lookup — profiles rarely take
  arguments explicitly at include sites.
- A boolean `manage_*` / `enable_*` parameter (usually defaulting to `false`) gates whether
  the profile does anything, so the class can be included broadly and turned on per role.
- Hashes of resources come from `lookup(..., Hash, 'deep', {})` + `create_resources`, which
  lets node/role YAML add entries on top of common defaults.
- Templates live under `profile/templates/<subsystem>/…` and are referenced as
  `template("${module_name}/…")`; static files under `profile/files/`.
- Custom facts are in `profile/lib/facter/` (`ceph_osd`, `kernel_modules`, `lspci_has`,
  `detect_intel_x710`, `kernel_file`).
- `modules/` is gitignored and exists only for local module development — modules placed
  there win, since `/opt/himlar/modules` is first on the basemodulepath.

### Puppet environments and Puppetfiles

The Puppet environment name selects the OpenStack release. `Puppetfile` (root) holds
modules shared by every environment; `puppetfiles/<env>.Puppetfile` holds the
release-specific OpenStack modules (`yoga.Puppetfile`, `zed.Puppetfile`,
`yoga_el9.Puppetfile`, `production_el9.Puppetfile`, …). All entries are pinned by `:ref`
to a git tag or SHA — keep that style when adding modules.

The environment is set per node: `puppet_env` in `nodes.yaml` for Vagrant, the node's
puppet config in production. `openstack_version` in Hiera must be kept consistent with the
environment actually deployed — several node and role files carry a local
`openstack_version` override during migrations.

## Conventions

- Hieradata is YAML with `---`, values commonly aligned in a column; `%{::fact}` and
  `%{hiera('key')}` interpolation is used heavily.
- Commit subjects are short and imperative, often scoped: `feat(bgo): …`, `el9: <old> -> <new>`,
  `Fix: …`. Many commits touch only one node or role YAML file.
- Locations must be listed in `valid_location_tags` in `hieradata/common/common.yaml`.
- `tests/` holds numbered shell scripts that exercise a running cloud via the OpenStack
  CLI; they are not part of `rake test`.
