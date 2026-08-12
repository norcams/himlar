# Skyline dashboard

Skyline is the replacement for Horizon. This directory holds the bits that
cannot be done from puppet, the rest of the setup lives in

| what | where |
| --- | --- |
| puppet profile | `profile/manifests/openstack/skyline.pp` |
| config templates | `profile/templates/openstack/skyline/` |
| service configuration | `hieradata/common/modules/skyline.yaml` |
| role (public dashboard) | `hieradata/common/roles/skyline.yaml` |
| role (internal/admin) | `hieradata/common/roles/skyline-mgmt.yaml` |
| location overrides | `hieradata/{bgo,osl,test01,vagrant}/roles/skyline.yaml` |

Upstream docs:

* <https://docs.openstack.org/skyline-console/latest/>
* <https://docs.openstack.org/skyline-console/latest/install/source-install-rhel.html>
* <https://docs.openstack.org/skyline-apiserver/latest/>

Our console fork: <https://github.com/caleno/skyline-console>

## How it hangs together

Skyline is two pieces:

* **skyline-apiserver** — a python (gunicorn/uvicorn) service. It authenticates
  against keystone, hands out a JWT session cookie and answers `/api/v1/*`.
  It also decides which policy rules the logged in user passes, which is what
  the console uses to decide what to show.
* **skyline-console** — a static javascript bundle, shipped as a python wheel
  and served by nginx. nginx also reverse proxies every openstack API under
  `/api/openstack/<region>/<service>/`.

The profile manages, on the skyline node:

```
/etc/skyline/skyline.yaml                  from profile::openstack::skyline::config (hiera, deep merged)
/etc/skyline/gunicorn.py                   bind = <bind_address>:<bind_port>
/etc/skyline/alembic.ini                   only used by the one-off db sync
/etc/skyline/policy/<service>_policy.yaml  from profile::openstack::skyline::policies
/etc/systemd/system/skyline-apiserver.service
/etc/nginx/nginx.conf
```

The install guide tells you to run `skyline-nginx-generator` to produce
`nginx.conf`. We do not: it needs to talk to keystone on every puppet run and
it would fight puppet over the file. Instead the same config is rendered from
`profile::openstack::skyline::proxy_endpoints`, which is filled from the
`endpoint__*__public` values we already keep in hiera. If a new service is
added to the catalog it has to be added there **and** to `service_mapping` in
`hieradata/common/modules/skyline.yaml`.

## Mimicking the Horizon setup

Horizon's user facing behaviour comes from three places, and each one has an
equivalent here.

### 1. Policy overrides — `profile::openstack::skyline::policies`

Same mechanism, same hiera shape (`openstacklib::policy::base`) as
`profile::openstack::dashboard::policies`, only the path changes from
`/etc/openstack-dashboard/<service>_policy.yaml` to
`/etc/skyline/policy/<service>_policy.yaml`.

The api server re-reads these files when they change, so no restart is needed.
Skyline asks itself the same questions the console asks, so a denied rule
removes the button from the UI instead of producing a failed API call.

One translation was needed: horizon used `rule:system_admin` to mean "nobody,
because the dashboard never holds a system scoped token". Skyline does not
register a `system_admin` rule, so an unresolved rule would only be denied by
accident — we use `!` instead, which means the same thing explicitly.

### 2. Services that are not offered — `service_mapping` / `extension_mapping`

Skyline hides a menu entry when the service behind it has no endpoint. By
listing only the services we run in `service_mapping`, and by leaving
`extension_mapping` empty, the following disappear without touching the
console: Load Balancers, Certificates, VPNs, Firewalls, QoS Policies, Share
File Storage, Key Manager, Orchestration, Databases, Containers and the
ironic parts of the compute menu.

### 3. Panels horizon unregisters — the console patch

`profile/files/openstack/horizon/overrides.py` unregisters a handful of panels.
The skyline menu is compiled into the bundle, so the equivalent lives in
`nrec-console.patch`, applied when the wheel is built:

| horizon (overrides.py) | skyline |
| --- | --- |
| Network → Networks | menu gated on `create_network` |
| Network → Routers | menu gated on `create_router` |
| Network → Floating IPs | menu gated on `create_floatingip` |
| Network → Network Topology | menu gated on `create_network` |
| Compute → API Access | no such panel in skyline |
| Identity → Users | admin console only, admin role required |
| Identity → Application Credentials | menu gated on `keystone:identity:create_application_credential` |
| Settings → Change Password | no such panel in skyline |
| DNS → Reverse DNS | `hidden: true` |
| `AssociateIP.allowed = NO` | `os_compute_api:os-floating-ips:add` denied |

The entries that are gated on a policy rule are the interesting ones: what is
visible is then decided by hiera, per location, without rebuilding anything.
`hidden: true` is used where there is no sensible rule to hang it on (Ports,
Reverse DNS) and where horizon has no panel to begin with.

Known difference from horizon: horizon *unregisters* a panel, which also kills
its url. Hiding a skyline menu entry leaves the route in the bundle, so someone
who types the url still reaches the page — but with the policy overrides above
they get an empty list and no buttons. Removing the routes as well would mean
patching `src/pages/*/routes/index.js`, which conflicts on every rebase, so we
do not.

## Building the console

```
./build-console.sh [build directory]
```

Clones the fork, applies `nrec-console.patch`, drops in the NREC logos from
`profile/files/openstack/horizon/img/` and runs `make package`. Upload the
resulting wheel to the package repo and point
`profile::openstack::skyline::pip_packages` at it.

When rebasing the fork on a new upstream release, re-apply the patch by hand
if it conflicts and regenerate it with `git diff > nrec-console.patch`.

## Adding a skyline node

1. Give it a name that resolves to the `skyline` role, e.g. `bgo-skyline-01`
   (`bgo-skyline-mgmt-01` for the internal one).
2. Add a node file under `hieradata/nodes/<location>/` with mgmt `.52`,
   trp `.52` and the public address, see the vagrant node file for an example.
3. Add the public address and the DNS records (`skyline.nrec.no`,
   `skyline-bgo.nrec.no`, `skyline-osl.nrec.no`) in the location hieradata.
4. Make sure the certificate for that name is in place at
   `/etc/pki/tls/{certs,private}/<name>.{cert,key}.pem`.
5. Run puppet on the identity node first (creates the `skyline` service user)
   and on `db-regional` (creates the `skyline` database).

Secrets needed in the secrets repo:

```
skyline_api_password:   # keystone password for the skyline service user
skyline_db_password:    # mariadb password, same user for both databases
skyline_secret_key:     # signing key for the session cookie, keep it secret
```

The vagrant/local hieradata has development values for these.

## WebSSO (Feide)

Skyline builds its callback url as
`https://<host>/api/openstack/skyline/api/v1/websso`, and keystone will only
redirect to a url it trusts, so the three public skyline addresses are listed
in `keystone::federation::trusted_dashboards`
(`hieradata/common/modules/keystone.yaml`). The protocol name (`openid`) has
to match `keystone::federation::openidc::methods`.
