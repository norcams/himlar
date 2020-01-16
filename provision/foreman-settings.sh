#!/bin/bash

# Be conservative
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

#
# Collect data
#
foreman_fqdn=$(hostname -f)
foreman_domain=${foreman_fqdn#*.}
foreman_location=${foreman_fqdn%%-*}
mgmt_interface=eth0
#mgmt_interface=$(hiera foreman_proxy::dhcp_interface role=foreman location=$foreman_location)
mgmt_network=$(facter network_${mgmt_interface})
mgmt_netmask=$(facter netmask_${mgmt_interface})
#repo=$(sed -n 's/^baseurl=//p' CentOS-Base.repo | head -1 | rev | cut -d/ -f3- | rev)
repo=$(sed -n 's/^baseurl=//p' /etc/yum.repos.d/CentOS-Base.repo | head -1)

#
# Location specific configs
#
vagrant_config()
{
  #
  # Use the internal DNS server on vagrant, switch to it using Puppet
  #
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
}

bgo_config()
{
  return;
}
osl_config()
{
  return;
}
#
# Common configuration
#
common_config()
{
  #
  # Network configuration objects
  #

  # Create and update domain
  /bin/hammer domain create --name $foreman_domain || true
  /bin/hammer domain update --name $foreman_domain
  foreman_domain_id=$(/bin/hammer --csv domain info --name $foreman_domain | tail -n1 | cut -d, -f1)

  # Find smart proxy ID to use for tftp
  foreman_proxy_id=$(/bin/hammer --csv proxy info --name $foreman_fqdn | tail -n1 | cut -d, -f1)

  # Find IDs for the default organization and location
  foreman_location_id=$(/bin/hammer --csv location list | grep 'Default Location' | cut -d, -f1)
  foreman_organization_id=$(/bin/hammer --csv organization list | grep 'Default Organization' | cut -d, -f1)

  # Create and update subnet
  /bin/hammer subnet create --name mgmt \
    --network         $mgmt_network \
    --organization-id $foreman_organization_id \
    --location-id     $foreman_location_id \
    --mask            $mgmt_netmask || true
  /bin/hammer subnet update --name mgmt \
    --network         $mgmt_network \
    --mask            $mgmt_netmask \
    --ipam            None \
    --domain-ids      $foreman_domain_id \
    --tftp-id         $foreman_proxy_id \
    --dns-primary     '' \
    --dns-secondary   '' \
    --gateway         '' \
    --organization-id $foreman_organization_id \
    --location-id     $foreman_location_id
#    --dns-id        '' \
#    --dhcp-id       ''
  foreman_subnet_id=$(/bin/hammer --csv subnet info --name mgmt | tail -n1 | cut -d, -f1)

  #
  # Provisioning and discovery setup
  #

  # Disable upstream epel and use norcams mirror
  /bin/hammer global-parameter set --name enable-epel --value false
  /bin/hammer global-parameter set --name enable-norcams-epel --value true

  # Enable norcam's mirror of puppet 5 and disable others
  /bin/hammer global-parameter set --name enable-puppetlabs-repo --value false
  /bin/hammer global-parameter set --name enable-puppetlabs-pc1-repo --value false
  /bin/hammer global-parameter set --name enable-puppet5 --value true
  /bin/hammer global-parameter set --name enable-norcams-repo --value true
  /bin/hammer global-parameter set --name run-puppet-in-installer --value true

  # Run puppet at first boot after install
  /bin/hammer global-parameter set --name puppet_systemd_firstboot --value true

  # Enable clokcsync in Kickstart
  /bin/hammer global-parameter set --name time-zone --value 'Europe/Oslo'
  /bin/hammer global-parameter set --name ntp-server --value 'no.pool.ntp.org'

  # Create ftp.uninett.no medium
  /bin/hammer medium create --name 'CentOS download.iaas.uio.no' \
    --os-family Redhat \
    --organization-id $foreman_organization_id \
    --location-id $foreman_location_id \
    --path $repo || true
  # Save CentOS mirror ids
  medium_id_1=$(/bin/hammer --csv medium info --name 'CentOS mirror' | tail -n1 | cut -d, -f1)
  medium_id_2=$(/bin/hammer --csv medium info --name 'CentOS download.iaas.uio.no' | tail -n1 | cut -d, -f1)

  # Sync our custom provision templates
  /sbin/foreman-rake templates:sync \
    repo="https://github.com/norcams/community-templates.git" branch="master" associate="always" prefix="norcams "
  # Save template ids
  norcams_provision_id=$(/bin/hammer --csv template list --per-page 1000 | grep ',norcams Kickstart default,' | cut -d, -f1)
  norcams_pxelinux_id=$(/bin/hammer --csv template list --per-page 1000 | grep 'norcams Kickstart default PXELinux' | cut -d, -f1)
  norcams_ptable_id=$(/bin/hammer --csv partition-table list --per-page 1000 | grep 'norcams Kickstart default' | cut -d, -f1)

  # Associate partition template with Redhat family of OSes
  /bin/hammer partition-table update --id $norcams_ptable_id \
      --organization-id $foreman_organization_id \
      --location-id $foreman_location_id --os-family Redhat

  # Create and update OS
  /bin/hammer --csv os list --per-page 1000 | grep 'CentOS 7' || /bin/hammer os create --name CentOS --major 7 --minor 7 || true
  for centos_os in $(/bin/hammer --csv os list --per-page 1000 | grep 'CentOS 7.7' | cut -d, -f1); do
    /bin/hammer os update --id $centos_os --name CentOS --major 7\
      --family Redhat \
      --architecture-ids 1 \
      --medium-ids ${medium_id_2} \
      --partition-table-ids $norcams_ptable_id \
    # Set default Kickstart and PXELinux templates and associate with os
    /bin/hammer template update --id $norcams_provision_id \
      --operatingsystem-ids $centos_os \
      --organization-id $foreman_organization_id \
      --location-id $foreman_location_id
    /bin/hammer template update --id $norcams_pxelinux_id \
      --operatingsystem-ids $centos_os \
      --organization-id $foreman_organization_id \
      --location-id $foreman_location_id
    /bin/hammer os set-default-template --id $centos_os \
      --config-template-id $norcams_provision_id
    /bin/hammer os set-default-template --id $centos_os \
      --config-template-id $norcams_pxelinux_id
  done

  # Create Puppet environment
  /bin/hammer environment create --name production \
    --organization-id $foreman_organization_id \
    --location-id $foreman_location_id || true

  # Create a base hostgroup
  /bin/hammer hostgroup create --name base || true
  /bin/hammer hostgroup update --name base \
    --architecture x86_64 \
    --domain-id $foreman_domain_id \
    --operatingsystem-id $centos_os \
    --medium-id $medium_id_2 \
    --partition-table-id $norcams_ptable_id \
    --subnet-id $foreman_subnet_id \
    --puppet-proxy-id $foreman_proxy_id \
    --puppet-ca-proxy-id $foreman_proxy_id \
    --environment production \
    --pxe-loader 'PXELinux BIOS' \
    --organization-id $foreman_organization_id \
    --location-id $foreman_location_id

  # Create storage hostgroup to set special paramters
  /bin/hammer hostgroup create --name storage --parent base \
     --organization-id $foreman_organization_id \
     --location-id $foreman_location_id || true
  /bin/hammer hostgroup set-parameter --hostgroup storage \
     --name installdevice \
     --value sdl
  # Create compute hostgroup to set special paramters
  /bin/hammer hostgroup create --name compute --parent base \
     --organization-id $foreman_organization_id \
     --location-id $foreman_location_id || true
  /bin/hammer hostgroup set-parameter --hostgroup compute \
     --name installdevice \
     --value sda
  #
  # Foreman global settings
  #
  # Thee last block below render the PXElinux default template with safe mode
  # rendering 'false'
  # - this is required for the discovery image to get the foreman_url setting
  # passed through to the kernel from the template
  #
  rootpw='Himlarchangeme'
  rootpw_md5=$(openssl passwd -1 $rootpw)
  echo '
    Setting["root_pass"]                    = "'$rootpw_md5'"
    Setting["entries_per_page"]             = 100
    Setting["foreman_url"]                  = "https://'$foreman_fqdn'"
    Setting["unattended_url"]               = "http://'$foreman_fqdn'"
    Setting["trusted_puppetmaster_hosts"]   = [ "'$foreman_fqdn'" ]
    Setting["discovery_fact_column"]        = "ipmi_ipaddress"
    Setting["update_ip_from_built_request"] = true
    Setting["use_shortname_for_vms"]        = true
    Setting["idle_timeout"]                 = 180

    Setting["safemode_render"] = false
    include Foreman::Renderer
    ProvisioningTemplate.build_pxe_default(self)
    Setting["safemode_render"] = true

  ' | /sbin/foreman-rake console
}

#
# main
#
case $foreman_fqdn in
  vagrant-foreman-*)
    vagrant_config
    ;;
  bgo-foreman-*)
    bgo_config
    ;;
  osl-foreman-*)
    osl_config
    ;;

esac
common_config
