#!/bin/bash

foreman-rake config -- -k foreman_url -v http://10.0.3.15
foreman-rake config -- -k unattended_url -v http://10.0.3.15

hammer domain create --name "vagrant.local"
hammer domain info --name "vagrant.local"

hammer subnet create --name "mgmt" \
  --network "10.0.3.0" \
  --mask "255.255.255.0" \
  --gateway "10.0.3.15" \
  --dns-primary "10.0.2.15"

hammer subnet update --name "mgmt" \
  --domain-ids $(hammer domain list | grep "vagrant.local" | head -c1)
hammer subnet update --name "mgmt" \
  --dhcp-id $(hammer proxy list | grep foreman | head -c2)
hammer subnet update --name "mgmt" \
  --tftp-id $(hammer proxy list | grep foreman | head -c2)
hammer subnet update --name "mgmt" \
  --dns-id $(hammer proxy list | grep foreman | head -c2)
hammer subnet info --name "mgmt"
hammer subnet update --name "mgmt" --from 10.0.3.100 --to 10.0.3.199

#hammer subnet create --name "oob" \
#  --network "129.240.224.64" \
#  --mask "255.255.255.224" \
#  --gateway "129.240.224.65" \
#  --dns-primary "129.240.2.3" \
#  --dns-secondary "129.240.2.40"
#
#hammer subnet update --name "oob" \
#  --domain-ids $(hammer domain list | grep "vagrant.local" | head -c1)

hammer environment create --name "production"
hammer environment info --name "production"

wget -P /tmp http://folk.uib.no/edpto/provision_openstack.erb
wget -P /tmp http://folk.uib.no/edpto/provision_kickstart_ifs.erb

hammer template create --name "Kickstart_openstack" --type provision --file /tmp/provision_openstack.erb
hammer template create --name "Kickstart default PXELinux ifs" --type PXELinux --file /tmp/provision_kickstart_ifs.erb

hammer os create --name CentOS --major 7 --minor 0.1406 --description "CentOS 7.0" --family Redhat \
  --architecture-ids 1 \
  --medium-ids $(hammer medium list | grep CentOS | head -c1) \
  --ptable-ids $(hammer partition-table list | grep "Kickstart default" | head -c1) 

hammer template update --name "Kickstart default PXELinux ifs" --operatingsystem-ids 1
hammer template update --name "Kickstart_openstack" --operatingsystem-ids 1

hammer os set-default-template --id 1 \
  --config-template-id $(hammer template list --per-page 10000 | grep "Kickstart_openstack"|cut -d" " -f1) 
hammer os set-default-template --id 1 \
  --config-template-id $(hammer template list --per-page 10000 | grep "Kickstart default PXELinux ifs" | cut -d" " -f1)
hammer os update --id 1 \
  --ptable-ids $(hammer partition-table list --per-page 10000 | grep "Kickstart default" | cut -d" " -f1)

hammer proxy import-classes --environment "production" --id $(hammer proxy list | grep 127 | head -c2) 

# Get our custom provision templates
foreman-rake templates:sync repo="https://github.com/norcams/community-templates.git" branch="norcams"

# Find id for safemode_render
safemode=$(curl -s -S -k -u admin:$1 http://127.0.0.1/api/v2/settings/?search="Safemode_render" | grep id | cut -d ',' -f1 | sed 's/[^0-9]*//g')

# Set Safemode_render to true or false - return true or false
settingid=$(echo $(curl -s -S -k -u admin:$1 http://127.0.0.1/api/v2/settings/$safemode/?search="Safemode_render"?page="true") | cut -d ',' -f1 | sed 's/[^0-9]*//g') && myresult=$(curl -s -S -k -u admin:$1 -X PUT -H "Content-Type:application/json" -H "Accept:application/json,version=2" -d "{\"setting\": {\"value\": \"false\"}}" http://127.0.0.1/api/v2/settings/$settingid) && echo "$myresult" | sed -e 's/.*value//g' | tr -dc '[:alnum:]\n\r'

# Deploy new default pxe config to smart proxy
curl -k -u admin:$1 http://127.0.0.1/api/v2/config_templates/build_pxe_default

settingid=$(echo $(curl -s -S -k -u admin:$1 http://127.0.0.1/api/v2/settings/$safemode/?search="Safemode_render"?page="true") | cut -d ',' -f1 | sed 's/[^0-9]*//g') && myresult=$(curl -s -S -k -u admin:$1 -X PUT -H "Content-Type:application/json" -H "Accept:application/json,version=2" -d "{\"setting\": {\"value\": \"true\"}}" http://127.0.0.1/api/v2/settings/$settingid) && echo "$myresult" | sed -e 's/.*value//g' | tr -dc '[:alnum:]\n\r'
