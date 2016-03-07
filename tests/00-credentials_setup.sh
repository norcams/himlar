#!/bin/bash

cat <<"END_CONFIG" > ~/openstack.config
os_url="http://172.31.24.20:35357/v3"
os_token="admintoken"
broken_osadmin()
{
  openstack --os-token $os_token --os-url $os_url "$@"
}

os_auth_url="http://172.31.24.20:5000/v3"
os_demo_username="demo"
os_demo_password="himlar0pen"
os_demo_project_name="demoproject"
osdemo()
{
  openstack --os-username $os_demo_username --os-password $os_demo_password --os-project-name $os_demo_project_name --os-auth-url $os_auth_url "$@"
}
END_CONFIG


cat <<'END_DEMO' > ~/keystonerc_demo
export OS_USERNAME=demo
export OS_TENANT_NAME=demoproject
export OS_PASSWORD=himlar0pen
export OS_AUTH_URL=http://172.31.24.20:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME:-"Default"}
export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME:-"Default"}
export PS1='\[\e[0;34m\][\u@\h \[\e[0;35m\]\W \[\e[0;33m\](demo)\[\e[0;34m\]]\$\[\e[0m\] '
export OS_NO_CACHE=1
alias openstack="/usr/bin/openstack"
unset http_proxy
unset https_proxy
END_DEMO


cat <<'END_ADMIN' > ~/keystonerc_admin
export OS_USERNAME=admin
export OS_TENANT_NAME=openstack
export OS_PASSWORD=admin_pass
export OS_REGION_NAME=vagrant
export OS_AUTH_URL=http://172.31.24.20:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME:-"Default"}
export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME:-"Default"}
export PS1='\[\e[0;34m\][\u@\h \[\e[0;35m\]\W \[\e[0;31m\](admin)\[\e[0;34m\]]\$\[\e[0m\] '
export OS_NO_CACHE=1
alias openstack="/usr/bin/openstack"
unset http_proxy
unset https_proxy
END_ADMIN
