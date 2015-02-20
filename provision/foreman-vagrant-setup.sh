#!/bin/bash

# Register foreman host in DNS
echo "server 10.0.3.15
      update add vagrant-foreman-dev.vagrant.local 3600 A 10.0.3.15
      send" | nsupdate -k /etc/rndc.key
# Register CNAMEs for foreman, puppetmaster
echo "server 10.0.3.15
      update add admin.vagrant.local 3600 CNAME vagrant-foreman-dev.vagrant.local.
      send" | nsupdate -k /etc/rndc.key
echo "server 10.0.3.15
      update add puppet.vagrant.local 3600 CNAME vagrant-foreman-dev.vagrant.local.
      send" | nsupdate -k /etc/rndc.key

foreman-rake config -- -k foreman_url -v https://admin.vagrant.local
foreman-rake config -- -k unattended_url -v https://admin.vagrant.local
# TODO fix puppemaster validation
foreman-rake config -- -k restrict_registered_puppetmasters -v false

hammer domain create --name "vagrant.local"
hammer domain info --name "vagrant.local"
hammer domain update --name "vagrant.local" --dns-id 1

hammer subnet create --name "mgmt" \
  --network "10.0.3.0" \
  --mask "255.255.255.0" \
  --gateway "10.0.3.15" \
  --dns-primary "10.0.2.15"

hammer subnet update --name "mgmt" \
  --domain-ids $(hammer domain list | grep "vagrant.local" | head -c1)

# Assume DHCP, TFTP and DNS is managed through proxy id 1
hammer subnet update --name "mgmt" --dhcp-id 1
hammer subnet update --name "mgmt" --tftp-id 1
hammer subnet update --name "mgmt" --dns-id 1
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

# Set up Puppet environment and import classes from proxy id 1
hammer environment create --name "production"
hammer environment info --name "production"
hammer proxy import-classes --environment "production" --id 1

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

# Get our custom provision templates
foreman-rake templates:sync repo="https://github.com/norcams/community-templates.git" branch="norcams"
# Set safemode_render to false
foreman-rake config -- -k safemode_render -v false
# Render new default pxe config to smart proxy
curl -k -u admin:$1 https://admin.vagrant.local/api/v2/config_templates/build_pxe_default
# Set safemode_render to true
foreman-rake config -- -k safemode_render -v true

