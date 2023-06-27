# This class is included from common.pp if is_virtual is false
#
class profile::base::physical (
  $enable_hugepages            = false,
  $hugepagesz                  = '2M',
  $hugepages                   = '245760',
  $enable_isolcpus             = false,
  $isolcpus                    = [],
  $blacklist_drv               = false,
  $blacklist_drv_list          = undef,
  $disable_intel_cstates       = false,
  $load_ahci_first             = false,
  $load_ahci_first_scsidrv     = 'mpt3sas',
  $load_ahci_last              = false,
  $load_ahci_last_scsidrv      = 'mpt3sas',
  $scsi_load_order             = false,
  $scsi_load_order_first       = undef,
  $scsi_load_order_second      = undef,
  $enable_network_tweaks       = false,
  $net_tweak_rmem_max          = '134217728',
  $net_tweak_wmem_max          = '134217728',
  $net_tweak_tcp_rmem          = '4096 87380 67108864',
  $net_tweak_tcp_wmem          = '4096 87380 67108864',
  $net_tweak_congest_ctrl      = 'htcp',
  $net_tweak_mtu_probing       = '1',
  $net_tweak_default_qdisc     = 'fq',
  $net_tweak_somaxconn         = '2048',
  $enable_redfish_sensu_check  = false,
  $enable_redfish_http_proxy   = undef,
  $package                     = 'lldpd',
  $service                     = 'lldpd',
  $efi_workaround              = false,
  $configure_bmc_nic           = false,
  $bmc_dns_server              = '192.168.0.10',
  $bmc_idrac_attributes = {
    'IPv4Static.1.Address'     => undef,
    'IPv4Static.1.Gateway'     => lookup('netcfg_oob_gateway', String, 'first', ''),
    'IPv4Static.1.Netmask'     => lookup('netcfg_oob_netmask', String, 'first', ''),
    'IPv4Static.1.DNSFromDHCP' => 'Disabled',
    'IPv4Static.1.DNS1'        => $bmc_dns_server,
    'IPv4.1.DHCPEnable'        => 'Disabled',
  },
  $bmc_generic_attributes = {
    'Address'       => undef,
    'Gateway'       => lookup('netcfg_oob_gateway', String, 'first', ''),
    'SubnetMask'    => lookup('netcfg_oob_netmask', String, 'first', ''),
    'AddressOrigin' => 'Static',
  },
) {

  # Configure 82599ES SFP+ interface module options
  if ($::lspci_has['intel82599sfp'] or $::lspci_has['intelx520sfp']) and 'ixgbe' in $::kernel_modules {
    # Set SFP option in /etc/modprobe.d/ixgbe.conf
    include ::kmod
    kmod::option { 'allow any SFPs':
      module => 'ixgbe',
      option => 'allow_unsupported_sfp',
      value  => '1',
    }
    # Set option in grub2
    kernel_parameter { 'ixgbe.allow_unsupported_sfp':
      ensure => present,
      value  => '1',
    }
  }

  # for intel based ceph osd servers disabling cpu c states provides significantly improved performance
  if $disable_intel_cstates {
    # Set options in grub2
    kernel_parameter { 'processor.max_cstate':
      ensure => present,
      value  => '1',
    }
    kernel_parameter { 'intel_idle.max_cstate':
      ensure => present,
      value  => '0',
    }
  }

  # to ensure that the Dell BOSS boot drive is always sda we can load the driver before any scsi driver
  if $load_ahci_first {
    file { "/etc/modprobe.d/${load_ahci_first_scsidrv}.conf":
      ensure  => present,
      content => "install ${load_ahci_first_scsidrv} /sbin/modprobe ahci; /sbin/modprobe --ignore-install ${load_ahci_first_scsidrv}\n",
      notify  => Exec['rebuild initramfs_first']
    }
    exec { 'rebuild initramfs_first':
      command     => 'dracut -f --kver $(rpm -qa kernel | sort -V -r | head -n 1 | sed \'s|kernel-||\')',
      path        => '/sbin:/usr/bin:/usr/sbin',
      refreshonly => true
    }
  }

  # to ensure that the Dell BOSS boot drive is always the last sd device we can load the driver after any scsi driver
  if $load_ahci_last {
    file { "/etc/modprobe.d/ahci.conf":
      ensure  => present,
      content => "install ahci /sbin/modprobe ${load_ahci_last_scsidrv}; /sbin/modprobe --ignore-install ahci\n",
      notify  => Exec['rebuild initramfs_last']
    }
    exec { 'rebuild initramfs_last':
      command     => 'dracut -f --kver $(rpm -qa kernel | sort -V -r | head -n 1 | sed \'s|kernel-||\')',
      path        => '/sbin:/usr/bin:/usr/sbin',
      refreshonly => true
    }
  }

  # older versions of the Foreman cannot chainload alma - so we just emulate centos
  if $efi_workaround and ($::operatingsystem == 'AlmaLinux') and ($enable_hugepages != true ) {
    exec { 'efi_workaround':
      command => 'cp -r /boot/efi/EFI/almalinux /boot/efi/EFI/centos',
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => 'test -d /boot/efi/EFI/centos',
    }
  }

  # for systems with multiple scsi controllers we need to define order
  if $scsi_load_order {
    file { "/etc/modprobe.d/${scsi_load_order_second}.conf":
      ensure  => present,
      content => "install ${scsi_load_order_second} /sbin/modprobe ${scsi_load_order_first}; /sbin/modprobe --ignore-install ${scsi_load_order_second}\n",
    }
  }

  if $enable_hugepages {
    kernel_parameter { 'hugepagesz':
      ensure => present,
      value  => $hugepagesz
    }
    kernel_parameter { 'hugepages':
      ensure => present,
      value  => $hugepages
    }
    kernel_parameter { 'transparent_hugepage':
      ensure => present,
      value  => 'never'
    }
    if $efi_workaround and ($::operatingsystem == 'AlmaLinux') {
      exec { 'efi_workaround_refresh':
        command     => 'cp -r /boot/efi/EFI/almalinux /boot/efi/EFI/centos',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        unless      => 'test -d /boot/efi/EFI/centos',
      }
    }
  }

  if $blacklist_drv {
    include ::kmod
    $blacklist_drv_list.each | $name, $data | {
      kmod::blacklist { $name:
        * => $data,
      }
    }
  }

  if $enable_network_tweaks {
    sysctl::value { "net.core.rmem_max":
      value => $net_tweak_rmem_max
    }
    sysctl::value { "net.core.wmem_max":
      value => $net_tweak_wmem_max,
    }
    sysctl::value { "net.ipv4.tcp_rmem":
      value => $net_tweak_tcp_rmem,
    }
    sysctl::value { "net.ipv4.tcp_wmem":
      value => $net_tweak_tcp_wmem,
    }
    sysctl::value { "net.ipv4.tcp_congestion_control":
      value => $net_tweak_congest_ctrl,
    }
    sysctl::value { "net.ipv4.tcp_mtu_probing":
      value => $net_tweak_mtu_probing,
    }
    sysctl::value { "net.core.default_qdisc":
      value => $net_tweak_default_qdisc,
    }
    sysctl::value { "net.core.somaxconn":
      value => $net_tweak_somaxconn,
    }
  }

  if $enable_isolcpus {
    kernel_parameter { 'isolcpus':
      ensure => present,
      value  => join($isolcpus, ',')
    }
  }

  # For Intel X710 Converged NICs we must disable the internal lldp service for lldpd to work in os. Run at every boot
  unless empty($::intel_x710) {
    $x710_nics = $::intel_x710
    $x710_nics.each |$pci_number| {
      file { "lldp-x710-${pci_number}.service":
        ensure  => file,
        path    => "/etc/systemd/system/lldp-x710-${pci_number}.service",
        content => template("${module_name}/base/physical/disable_x710_lldp_service.erb"),
      } ~>
      service { "Disable internal lldp in nic - slot ${pci_number}":
        enable      => true,
        hasrestart  => false,
        name        => "lldp-x710-${pci_number}",
      }
    }
  }

  package { $package:
    ensure => installed,
  }

  service { $service:
    ensure    => running,
    enable    => true,
  }

  if ($enable_redfish_sensu_check) and ($::runmode == 'default') {
    $bmc_network  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\2',) - 1
    $bmc_address  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$',"\\1.${bmc_network}.\\3.\\4",)
    $bmc_username = lookup("bmc_username", String, 'first', '')
    $bmc_password = lookup("bmc_password_${::location}", String, 'first', '')
    if $enable_redfish_http_proxy {
      $http_proxy     = lookup('mgmt__address__proxy', String, 'first', '')
      $http_proxy_url = " --proxy1.0 ${http_proxy}:8888"
    }
    case $facts['manufacturer'] {
      'Dell Inc.': {
        $connection_string = '/redfish/v1/Systems/System.Embedded.1'
      }
      'Supermicro': {
        $connection_string = '/redfish/v1/Systems/1'
      }
      'Huawei': {
        $connection_string = '/redfish/v1/Systems/1'
      }
      default: {
        $connection_string = '/redfish/v1/Systems/1'
      }
    }
    file { 'redfish_status.sh':
      ensure  => file,
      path    => '/usr/local/bin/redfish_check.sh',
      content => template("${module_name}/monitoring/sensu/redfish_check.sh.erb"),
      mode    => '0755',
    }

    if $facts['manufacturer'] == 'Dell Inc.' {
      include profile::monitoring::physical::power
    }
  }

  # FIXME: This should be done more efficient when more vendors enter our scene
  if ($configure_bmc_nic) and ($::runmode == 'default') {
    $addresslist = lookup('profile::network::services::dns_records', Hash, 'deep', '')
    $cname = $addresslist['CNAME'][$::clientcert]
    if empty($cname) {
      $mgmtaddress = $addresslist['A'][$::clientcert]
    }
    else {
      $mgmtaddress = $addresslist['A'][$cname]
    }
    # Configure only if this nodes network seems to be properly configured to avoid snafus
    if ($mgmtaddress) == ($::ipaddress_mgmt1) {
      $bmc_network_set  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\2',) - 1
      $bmc_address_set  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$',"\\1.${bmc_network_set}.\\3.\\4",)
      $bmc_username_set = lookup("bmc_username", String, 'first', '')
      $bmc_password_set = lookup("bmc_password_${::location}", String, 'first', '')
      if $enable_redfish_http_proxy {
        $http_proxy_set     = lookup('mgmt__address__proxy', String, 'first', '')
        $http_proxy_url_set = " --proxy1.0 ${http_proxy_set}:8888"
      }
      case $facts['manufacturer'] {
        'Dell Inc.': {
          unless $facts['productname'] =~ '(FC|[RTM])[1-9][1-3]\d.*' {
            $bmc_idrac_attributes.each |$attribute, $value| {
              if ($attribute == 'IPv4Static.1.Address') and (!$value) {
                $attr_value = $bmc_address_set
              }
              else {
                $attr_value = $value
              }
              exec { "Set bmc static configuration - ${attribute}":
                command     => "/bin/curl -f -s https://${bmc_address_set}/redfish/v1/Managers/iDRAC.Embedded.1/Attributes -k -u ${bmc_username_set}:${bmc_password_set} ${http_proxy_url_set} --connect-timeout 20 -X PATCH -H \"Content-Type: application/json\" -d \'{\"Attributes\" : {\"${attribute}\":\"${attr_value}\"}}\' && /bin/touch /etc/.bmc_configured-${attribute}",
                creates     => "/etc/.bmc_configured-${attribute}",
              }
            }
          }
        }
        'Supermicro': {
          $bmc_generic_attributes.each |$attribute, $value| {
            if ($attribute == 'Address') and (!$value) {
              $attr_value = $bmc_address_set
            }
            else {
              $attr_value = $value
            }
            exec { "Set bmc static configuration - ${attribute}":
              command     => "/bin/curl -f -s https://${bmc_address_set}/redfish/v1/Managers/1/EthernetInterfaces/1 -k -u ${bmc_username_set}:${bmc_password_set} ${http_proxy_url_set} --connect-timeout 20 -X PATCH -H \"Content-Type: application/json\" -d \'{\"IPv4Addresses\" : {\"${attribute}\":\"${attr_value}\"}}\' && /bin/touch /etc/.bmc_configured-${attribute}",
              creates     => "/etc/.bmc_configured-${attribute}",
            }
          }
        }
        'Huawei': {
          notice('We can not configure network for Huawei ibmc')
        }
        default: {
          notice('BMC for this vendor is not supported')
        }
      }
    }
  }
}
