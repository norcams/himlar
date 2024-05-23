#!/bin/bash

cat <<'END_DEMO' > ~/keystonerc_demo
export OS_USERNAME=demo
export OS_PROJECT_NAME=demoproject
export OS_PASSWORD=himlar0pen
export OS_AUTH_URL="https://api.iaas.intern:5000/v3"
export OS_IDENTITY_API_VERSION=3
export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME:-"Default"}
export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME:-"Default"}
export OS_REGION_NAME="vagrant"
export OS_NO_CACHE=1
export OS_CACERT=/opt/himlar/provision/ca/intermediate/certs/ca-chain.cert.pem
alias openstack="/usr/bin/openstack"
unset http_proxy
unset https_proxy
export PS1='\[\e[0;34m\][\u@\h \[\e[0;35m\]\W \[\e[0;33m\](demo)\[\e[0;34m\]]\$\[\e[0m\] '
END_DEMO
