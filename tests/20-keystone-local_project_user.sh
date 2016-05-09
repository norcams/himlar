#!/bin/bash

# print help
function usage {
  echo "You must input a valid project name and new user email as input param!"
  echo "./${0} <project> > keystonerc_user"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

source ~/keystonerc_admin
project=$1
domain='dataporten'
password=$(cat /dev/urandom | tr -dc A-Z-a-z0-9 | head -c 12)

# Check if new user exits
openstack user list | grep ${project} > /dev/null
if [[ $? -eq 0 ]]; then
  usage
fi

# Check if project is valid
openstack project list | grep ${project} > /dev/null
if [[ $? -ne 0 ]]; then
  usage
fi

project_id=$(openstack project list | grep raymond.kristiansen@uib.no | awk '{ print $2 }')

openstack user create \
--domain ${domain} \
--project ${project_id} \
--email ${project} \
--password ${password} ${project} > /dev/null

openstack group add user ${project}-group ${project} > /dev/null

echo "
export OS_USERNAME=${project}
export OS_TENANT_NAME=${project}
export OS_PASSWORD=${password}
export OS_AUTH_URL=https://dashboard.himlar.local:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_CACERT=/opt/himlar/provision/ca/certs/ca-chain.cert.pem
export OS_USER_DOMAIN_NAME=dataporten
export OS_PROJECT_DOMAIN_NAME=dataporten
export PS1='\[\e[0;34m\][\u@\h \[\e[0;35m\]\W \[\e[0;33m\](local)\[\e[0;34m\]]\$\[\e[0m\] '
export OS_NO_CACHE=1
"

exit 0
