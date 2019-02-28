# Disable Floating IPs
from openstack_dashboard.dashboards.project.instances import tables
import horizon
import os.path

NO = lambda *x: False

tables.AssociateIP.allowed = NO
tables.SimpleDisassociateIP.allowed = NO

project_dashboard = horizon.get_dashboard("project")
identity_dashboard = horizon.get_dashboard("identity")
settings_dashboard = horizon.get_dashboard("settings")

# Remove the following panels from project

project_panels = list()

# Network->Routers
project_panels.append(project_dashboard.get_panel("routers"))
# Network->Networks
project_panels.append(project_dashboard.get_panel("networks"))
# Network->Network Topology
project_panels.append(project_dashboard.get_panel("network_topology"))
# Network->Floating IPs
project_panels.append(project_dashboard.get_panel("floating_ips"))
# Compute->API
project_panels.append(project_dashboard.get_panel("api_access"))
# Volumes-> Backups
project_panels.append(project_dashboard.get_panel("backups"))
# Volumes-> Consistency Groups
project_panels.append(project_dashboard.get_panel("cgroups"))
# Volumes-> Consistency Group Snapshots
project_panels.append(project_dashboard.get_panel("cg_snapshots"))
# DNS->Reverse DNS
if os.path.isfile("/usr/share/openstack-dashboard/openstack_dashboard/local/enabled/_1722_dns_reversedns_panel.py"):
    project_panels.append(project_dashboard.get_panel("reverse_dns"))

for panel in project_panels:
    project_dashboard.unregister(panel.__class__)

# Remove change password
password_panel = settings_dashboard.get_panel("password")
settings_dashboard.unregister(password_panel.__class__)

# Remove Identity-> Users
users_panel = identity_dashboard.get_panel("users")
identity_dashboard.unregister(users_panel.__class__)

# Object storage
container_panel = project_dashboard.get_panel("containers")
permissions = list()
permissions.append('openstack.roles.object')
container_panel.permissions = tuple(permissions)
