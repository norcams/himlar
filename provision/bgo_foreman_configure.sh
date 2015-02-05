#!/bin/bash

hammer domain create --name "bmc.iaas.intern"
hammer domain info --name "bmc.iaas.intern"
hammer domain create --name "mgmt.iaas.intern"
hammer domain info --name "mgmt.iaas.intern"

hammer subnet create --name "mgmt" \
  --network "172.16.32.0" \
  --mask "255.255.248.0" \
  --gateway "172.16.32.1" \
  --dns-primary "129.177.6.54" \
  --dns-secondary "129.177.12.31"

hammer subnet update --name "mgmt" \
  --domain-ids $(hammer domain list | grep "mgmt.iaas.intern" | head -c1)
hammer subnet update --name "mgmt" \
  --dhcp-id $(hammer proxy list | grep foreman | head -c2)
hammer subnet update --name "mgmt" \
  --tftp-id $(hammer proxy list | grep foreman | head -c2)
hammer subnet update --name "mgmt" \
  --dns-id $(hammer proxy list | grep foreman | head -c2)
hammer subnet info --name "mgmt"
hammer subnet update --name "mgmt" --from 172.16.32.200 --to 172.16.32.250

hammer subnet create --name "bmc" \
  --network "172.16.24.0" \
  --mask "255.255.248.0" \
  --gateway "172.16.24.1" \
  --dns-primary "129.177.6.54" \
  --dns-secondary "129.177.12.31"

hammer subnet update --name "bmc" \
  --domain-ids $(hammer domain list | grep "bmc.iaas.intern" | head -c1)

hammer environment create --name "production"
hammer environment info --name "production"

wget -P /tmp http://folk.uib.no/edpto/provision_openstack.erb
wget -P	/tmp http://folk.uib.no/edpto/provision_kickstart_ifs.erb

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

# Set Safemode_render to true or false - return true or false
settingid=$(echo $(curl -s -S -k -u admin:changeme http://127.0.0.1/api/v2/settings/28/?search="Safemode_render"?page="true") | cut -d ',' -f1 | sed 's/[^0-9]*//g') && myresult=$(curl -s -S -k -u admin:changeme -X PUT -H "Content-Type:application/json" -H "Accept:application/json,version=2" -d "{\"setting\": {\"value\": \"false\"}}" http://127.0.0.1/api/v2/settings/$settingid) && echo "$myresult" | sed -e 's/.*value//g' | tr -dc '[:alnum:]\n\r'

# Deploy new default pxe config to smart proxy
curl -k -u admin:changeme http://127.0.0.1/api/v2/config_templates/build_pxe_default

settingid=$(echo $(curl -s -S -k -u admin:changeme http://127.0.0.1/api/v2/settings/28/?search="Safemode_render"?page="true") | cut -d ',' -f1 | sed 's/[^0-9]*//g') && myresult=$(curl -s -S -k -u admin:changeme -X PUT -H "Content-Type:application/json" -H "Accept:application/json,version=2" -d "{\"setting\": {\"value\": \"true\"}}" http://127.0.0.1/api/v2/settings/$settingid) && echo "$myresult" | sed -e 's/.*value//g' | tr -dc '[:alnum:]\n\r'
