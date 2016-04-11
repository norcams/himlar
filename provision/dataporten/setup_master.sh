#!/bin/bash -ux

# configuration
domain="dataporten"
idp_name="dataporten"
idp_endpoint="https://auth.dataporten.no"
mapping_name="dataporten_personal"
mapping_rules="/opt/himlar/provision/dataporten/mapping_personal.json"
os_rc_file='/root/keystonerc_admin'

# Load openstack client credentials and settings
if [ ! -f "${os_rc_file}" ]; then
  echo "Could not find ${os_rc_file}."
  exit 1
fi

source "${os_rc_file}"

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
  curl --silent -o /tmp/mapping_personal.json https://raw.githubusercontent.com/norcams/himlar/master/provision/dataporten/mapping_personal.json
  # Find domain ID
  domain_id=$(openstack domain show $domain -f value -c id)
  # Replace DOMAIN_ID token with real ID in mapping rules
  sed "s/DOMAIN_ID/$domain_id/" /tmp/mapping_personal.json > /tmp/mapping.rules
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
