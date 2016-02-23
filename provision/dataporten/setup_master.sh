#!/bin/bash -ux

## find client credentials and settings file
if [ $# -ne 1 ]; then
  echo "Warning: no location provided. Using defaults for vagrant. To change run"
  echo "./setup_master.sh osl"
  os_rc_file="/opt/himlar/provision/dataporten/openstack.rc.vagrant"
else
  # Do not trust user to get this right!
  os_rc_file='/root/keystonerc_admin'
fi

# configuration
domain="dataporten"
idp_name="dataporten"
idp_endpoint="https://auth.feideconnect.no"
mapping_name="dataporten_personal"
mapping_rules="/opt/himlar/provision/dataporten/mapping_personal.json"

# Create domain
puppet apply --test /opt/himlar/provision/dataporten/dataporten_domain.pp

# Load openstack client credentials and settings
source "${os_rc_file}"

# Create user role
# check
openstack role list | grep user
# create
if [[ $? -ne 0 ]]; then
  openstack role create user
fi

# Create idp
# check
openstack identity provider list | grep ${idp_name}
# create
if [[ $? -ne 0 ]]; then
  openstack identity provider create "${idp_name}" --remote-id "${idp_endpoint}"
fi

# Create mapping
# check
openstack mapping list | grep ${mapping_name}
# create
if [[ $? -ne 0 ]]; then
  # Find domain ID
  domain_id=$(openstack domain show $domain -f value -c id)
  # Replace DOMAIN_ID token with real ID in mapping rules
  sed "s/DOMAIN_ID/$domain_id/" "${mapping_rules}" > /tmp/mapping.rules
  openstack mapping create "${mapping_name}" --rules /tmp/mapping.rules
fi

# Create protocol
# check
openstack federation protocol list --identity-provider "${idp_name}" | grep oidc
# create
if [[ $? -ne 0 ]]; then
  openstack federation protocol create oidc --identity-provider "${idp_name}" --mapping "${mapping_name}"
fi

systemctl restart httpd
