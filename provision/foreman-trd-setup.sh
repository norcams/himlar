#!/bin/bash -xv


# Register Foreman host in DNS and CNAMEs admin and puppet
echo "server dyndns.it.ntnu.no
      update add trd-foreman-bootstrap.mgmt.iaas.ntnu.no. 300 A 10.171.91.11
      update add admin.mgmt.iaas.ntnu.no. 3600 CNAME trd-foreman-bootstrap.mgmt.iaas.ntnu.no.
      update add puppet.mgmt.iaas.ntnu.no. 3600 CNAME trd-foreman-bootstrap.mgmt.iaas.ntnu.no.
      send" | nsupdate -k /etc/rndc.key

echo "server dyndns.it.ntnu.no
      update add 11.91.171.10.in-addr.arpa. 3600 PTR trd-foreman-bootstrap.mgmt.iaas.ntnu.no.
      send" | nsupdate -k /etc/rndc.key

#
# Foreman settings
#
rootpw='himlar-changeme'
rootpw_md5=$(openssl passwd -1 $rootpw)
echo '
  Setting["root_pass"]        = "'$rootpw_md5'"
  Setting["entries_per_page"] = 100
  Setting["foreman_url"]      = "https://admin.mgmt.iaas.ntnu.no"
  Setting["unattended_url"]   = "http://admin.mgmt.iaas.ntnu.no"
' | foreman-rake console

#
# Network configuration objects
#
hammer domain create --name "oob.iaas.ntnu.no"
hammer domain info --name "oob.iaas.ntnu.no"
hammer domain create --name "mgmt.iaas.ntnu.no"
hammer domain info --name "mgmt.iaas.ntnu.no"

hammer subnet create --name "mgmt" \
  --network "10.171.91.0" \
  --mask "255.255.255.0" \
  --gateway "10.171.91.1" \
  --dns-primary "129.241.0.200" \
  --dns-secondary "129.241.0.201"
hammer subnet update --name "mgmt" \
  --domain-ids $(hammer domain list | grep "mgmt.iaas.ntnu.no" | head -c1)
hammer subnet update --name "mgmt" \
  --dhcp-id 1
hammer subnet update --name "mgmt" \
  --tftp-id 1
hammer subnet update --name "mgmt" \
  --dns-id 1
hammer subnet info --name "mgmt"
hammer subnet update --name "mgmt" --from 10.171.91.200 --to 10.171.91.250
hammer domain update --name mgmt.iaas.ntnu.no --dns-id 1

hammer subnet create --name "oob" \
  --network "10.171.86.0" \
  --mask "255.255.255.0" \
  --gateway "10.171.86.1" \
  --dns-primary "129.241.0.200" \
  --dns-secondary "129.241.0.200"
hammer subnet update --name "oob" \
  --domain-ids $(hammer domain list | grep "oob.iaas.ntnu.no" | head -c1)
hammer domain update --name oob.iaas.ntnu.no --dns-id 1

#
# Puppet settings
#
# Enable Puppetlabs repo to enable Puppet bootstrap logic in kickstart template
hammer global-parameter set --name enable-puppetlabs-repo --value true
# Set up Puppet environment and import classes from proxy id 1
hammer environment create --name "production"
hammer environment info --name "production"
hammer proxy import-classes --environment "production" --id 1

#
# Provisioning and discovery setup
#

# TEMP FIX wrong url for some CentOS mirrors throug mirror.centos.org http://projects.theforeman.org/issues/6884
hammer medium update --id 1 --path 'http://centos.uib.no/$version/os/$arch'

# Download and create partition	table
wget -P http://folk.uib.no/edpto/provision_partition.erb
hammer partition-table create --name "Kickstart partition instdev" --os-family Redhat --file /tmp/provision_partition.erb

# Create OS
hammer os create --name CentOS --major 7 --minor 0.1406 --description "CentOS 7.0" --family Redhat \
  --architecture-ids 1 \
  --medium-ids $(hammer medium list | grep CentOS | head -c1) \
  --ptable-ids $(hammer partition-table list | grep "Kickstart partition instdev" | head -c1) 

# Download and create templates
wget -P /tmp http://folk.uib.no/edpto/provision_openstack.erb
wget -P	/tmp http://folk.uib.no/edpto/provision_kickstart_ifs.erb
hammer template create --name "Kickstart_openstack" --type provision --file /tmp/provision_openstack.erb
hammer template create --name "Kickstart default PXELinux ifs" --type PXELinux --file /tmp/provision_kickstart_ifs.erb
# Assign templates to OS
hammer template update --name "Kickstart default PXELinux ifs" --operatingsystem-ids 1
hammer template update --name "Kickstart_openstack" --operatingsystem-ids 1
hammer os set-default-template --id 1 \
  --config-template-id $(hammer template list --per-page 10000 | grep "Kickstart_openstack"|cut -d" " -f1) 
hammer os set-default-template --id 1 \
  --config-template-id $(hammer template list --per-page 10000 | grep "Kickstart default PXELinux ifs" | cut -d" " -f1)
hammer os update --id 1 \
  --ptable-ids $(hammer partition-table list --per-page 10000 | grep "Kickstart default" | cut -d" " -f1)

# Create a base hostgroup with all services on proxy id 1
hammer hostgroup create --name "base" --architecture "x86_64" --domain-id 1 --environment "production" --operatingsystem-id 1 --medium "CentOS mirror" --ptable "Kickstart default" --subnet-id 1 --puppet-proxy-id 1 --puppet-ca-proxy-id 1

# Get our custom provision templates
foreman-rake templates:sync repo="https://github.com/norcams/community-templates.git" branch="norcams"
# Render pxe default with safe mode rendering false - this is required for the discovery image
# to get the foreman_url setting passed through to the kernel from the template
echo '
  Setting["safemode_render"] = false
  include Foreman::Renderer
  ConfigTemplate.build_pxe_default(self)
  Setting["safemode_render"] = true
' | foreman-rake console
