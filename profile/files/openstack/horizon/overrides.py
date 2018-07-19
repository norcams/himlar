# Disable Floating IPs
from openstack_dashboard.dashboards.project.instances import tables
import horizon

NO = lambda *x: False

tables.AssociateIP.allowed = NO
tables.SimpleAssociateIP.allowed = NO
tables.SimpleDisassociateIP.allowed = NO

project_dashboard = horizon.get_dashboard("project")

# Hide object storage for users without object role
container_panel = project_dashboard.get_panel("containers")
permissions = list()
permissions.append('openstack.roles.object')
container_panel.permissions = tuple(permissions)

# Hide panel Network->Routers
routers_panel = project_dashboard.get_panel("routers")
permissions = list(getattr(routers_panel, 'permissions', []))
permissions.append('openstack.roles.admin')
routers_panel.permissions = tuple(permissions)

# Hide panel Network->Networks for all but admin
networks_panel = project_dashboard.get_panel("networks")
permissions = list(getattr(networks_panel, 'permissions', []))
permissions.append('openstack.roles.admin')
networks_panel.permissions = tuple(permissions)

# Hide panel Network->Network Topology for all but admin
topology_panel = project_dashboard.get_panel("network_topology")
permissions = list(getattr(topology_panel, 'permissions', []))
permissions.append('openstack.roles.admin')
topology_panel.permissions = tuple(permissions)

# Hide panel Network->Floating IPs for all but admin
floating_ips_panel = project_dashboard.get_panel("floating_ips")
permissions = list(getattr(floating_ips_panel, 'permissions', []))
permissions.append('openstack.roles.admin')
floating_ips_panel.permissions = tuple(permissions)

# Hide panel Compute->API Access for all but admin
api_access_panel = project_dashboard.get_panel("api_access")
permissions = list(getattr(api_access_panel, 'permissions', []))
permissions.append('openstack.roles.admin')
api_access_panel.permissions = tuple(permissions)

# Remove change password
settings = horizon.get_dashboard("settings")
password_panel = settings.get_panel("password")
settings.unregister(password_panel.__class__)

# Remove "Volume Consistency Groups" tab
from openstack_dashboard.dashboards.project.volumes import tabs
tabs.CGroupsTab.allowed = NO
