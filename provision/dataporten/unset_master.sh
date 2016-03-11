#!/bin/bash -ux

## find client credentials and settings file
if [ $# -ne 1 ]; then
  echo "Warning: no location provided. Using defaults for vagrant. To change run"
  echo "./unset_master.sh osl"
  os_rc_file="/opt/himlar/provision/dataporten/openstack.rc.vagrant"
else
  # Do not trust user to get this right!
  os_rc_file='/root/keystonerc_admin'
fi

# configuration
mapping_name="dataporten_personal"
idp_name="dataporten"

# Load openstack client credentials and settings
source "${os_rc_file}"

openstack federation protocol delete oidc --identity-provider "${idp_name}"
openstack mapping delete "${mapping_name}"
openstack identity provider delete "${idp_name}"
