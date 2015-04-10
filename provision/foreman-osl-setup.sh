#!/bin/bash -xv

#
# Register Foreman host in DNS and CNAMEs admin and puppet
#
echo "server 129.240.2.6
      update add osl-foreman-1.iaas.uio.no. 3600 A 129.240.224.101
      update add admin.iaas.uio.no. 3600 CNAME osl-foreman-1.iaas.uio.no.
      update add puppet.iaas.uio.no. 3600 CNAME osl-foreman-1.iaas.uio.no.
      send" | nsupdate -k /etc/rndc.key
#echo "server 129.240.2.6
#      update add 101.224.240.129.in-addr.arpa. 3600 PTR osl-foreman-1.iaas.uio.no.
#      send" | nsupdate -k /etc/rndc.key

#
# Foreman settings
#
rootpw='Himlarchangeme'
rootpw_md5=$(openssl passwd -1 $rootpw)
echo '
  Setting["root_pass"]        = "'$rootpw_md5'"
  Setting["entries_per_page"] = 100
  Setting["foreman_url"]      = "https://osl-foreman-1.iaas.uio.no"
  Setting["unattended_url"]   = "http://osl-foreman-1.iaas.uio.no"
' | foreman-rake console

#
# Network configuration objects
#
domain_opts="
  --name iaas.uio.no
  --dns-id 1
"
hammer domain create $domain_opts
hammer domain update $domain_opts

subnet_opts="
  --name mgmt
  --network 129.240.224.96
  --mask 255.255.255.224
  --gateway 129.240.224.97
  --dns-primary 129.240.2.3
  --dns-secondary 129.240.2.40
  --from 129.240.224.115
  --to 129.240.224.126
  --domain-ids "$(hammer domain list | grep "iaas.uio.no" | head -c1)"
  --dhcp-id 1
  --tftp-id 1
  --dns-id ''
"
#  --dns-id 1
#"
hammer subnet create $subnet_opts
hammer subnet update $subnet_opts

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
