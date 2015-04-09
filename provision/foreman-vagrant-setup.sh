#!/bin/bash

#
# DNS setup
#
# Switch to use own internal DNS
puppet apply -e "
augeas { 'peerdns no':
  context => '/files/etc/sysconfig/network-scripts/ifcfg-eth0',
  changes => [ 'set PEERDNS no' ],
}
augeas { 'switch nameserver':
  context => '/files/etc/resolv.conf',
  changes => [ 'set nameserver 10.0.3.5' ],
}
"
# Register Foreman host in DNS and CNAMEs admin and puppet
echo "server 10.0.3.5
      update add vagrant-foreman-dev.himlar.local 3600 A 10.0.3.5
      update add admin.himlar.local 3600 CNAME vagrant-foreman-dev.himlar.local.
      update add puppet.himlar.local 3600 CNAME vagrant-foreman-dev.himlar.local.
      send" | nsupdate -k /etc/rndc.key

#
# Foreman settings
#
rootpw='Himlarchangeme'
rootpw_md5=$(openssl passwd -1 $rootpw)
echo '
  Setting["root_pass"]        = "'$rootpw_md5'"
  Setting["entries_per_page"] = 100
  Setting["foreman_url"]      = "https://admin.himlar.local"
  Setting["unattended_url"]   = "http://admin.himlar.local"
' | foreman-rake console

#
# Network configuration objects
#
hammer domain create --name "himlar.local"
hammer domain info --name "himlar.local"
hammer domain update --name "himlar.local" --dns-id 1
hammer subnet create --name "mgmt" \
  --network "10.0.3.0" \
  --mask "255.255.255.0" \
  --gateway "10.0.3.1" \
  --dns-primary "10.0.3.5"
hammer subnet update --name "mgmt" \
  --domain-ids $(hammer domain list | grep "himlar.local" | head -c1)
# Assume DHCP, TFTP and DNS is managed through proxy id 1
hammer subnet update --name "mgmt" --dhcp-id 1
hammer subnet update --name "mgmt" --tftp-id 1
hammer subnet update --name "mgmt" --dns-id 1
hammer subnet info --name "mgmt"
hammer subnet update --name "mgmt" --from 10.0.3.100 --to 10.0.3.199
# Out of band mgmt network
#hammer subnet create --name "oob" \
#  --network "129.240.224.64" \
#  --mask "255.255.255.224" \
#  --gateway "129.240.224.65" \
#  --dns-primary "129.240.2.3" \
#  --dns-secondary "129.240.2.40"
#hammer subnet update --name "oob" \
#  --domain-ids $(hammer domain list | grep "himlar.local" | head -c1)

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

# Create OS
hammer os create --name CentOS --major 7 --description "CentOS 7" --family Redhat \
  --architecture-ids 1 \
  --medium-ids $(hammer medium list | grep CentOS | head -c1)

# Get our custom provision templates
foreman-rake templates:sync repo="https://github.com/norcams/community-templates.git" branch="0.2.0" associate="always"

hammer os set-default-template --id 1 \
  --config-template-id $(hammer template list --per-page 10000 | grep "norcams Kickstart default"|cut -d" " -f1)
hammer os set-default-template --id 1 \
  --config-template-id $(hammer template list --per-page 10000 | grep "norcams PXELinux default" |cut -d" " -f1)
hammer os update --id 1 \
  --ptable-ids $(hammer partition-table list --per-page 10000  | grep "norcams ptable default"   |cut -d" " -f1)

# Create a base hostgroup with all services on proxy id 1
hammer hostgroup create --name "base" --architecture "x86_64" --domain-id 1 --environment "production" --operatingsystem-id 1 --medium "CentOS mirror" --ptable "norcams ptable default" --subnet-id 1 --puppet-proxy-id 1 --puppet-ca-proxy-id 1

# Render pxe default with safe mode rendering false - this is required for the discovery image
# to get the foreman_url setting passed through to the kernel from the template
echo '
  Setting["safemode_render"] = false
  include Foreman::Renderer
  ConfigTemplate.build_pxe_default(self)
  Setting["safemode_render"] = true
' | foreman-rake console
