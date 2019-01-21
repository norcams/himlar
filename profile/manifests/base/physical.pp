# This class is included from common.pp if is_virtual is false
#
class profile::base::physical (
  $enable_redfish_sensu_check  = false,
  $enable_redfish_http_proxy   = undef,
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
) {
  include ::lldp
  include ::ipmi

  # Configure 82599ES SFP+ interface module options
  if $::lspci_has['intel82599sfp'] and 'ixgbe' in $::kernel_modules {
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

  if ($enable_redfish_sensu_check) and ($::runmode == 'default') {
    $bmc_network  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\2',) - 1
    $bmc_address  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$',"\\1.${bmc_network}.\\3.\\4",)
    $bmc_username = lookup("bmc_username", String, 'first', '')
    $bmc_password = lookup("bmc_password_${::location}", String, 'first', '')
    if $enable_redfish_http_proxy {
      $http_proxy     = lookup('mgmt__address__proxy', String, 'first', '')
      $http_proxy_url = " --proxy1.0 ${http_proxy}:8888"
    }
    file { 'redfish_status.sh':
      ensure  => file,
      path    => '/usr/local/bin/redfish_check.sh',
      content => template("${module_name}/monitoring/sensu/redfish_check.sh.erb"),
      mode    => '0755',
    }
  }

  # FIXME: This must be expanded to support bmcs other than Dell iDRAC
  if ($configure_bmc_nic) and ($::runmode == 'default') {
    $addresslist = lookup('profile::network::services::dns_records', Hash, 'deep', '')
    $mgmtaddress = $addresslist['A'][$::clientcert]
    # Configure only if this nodes network seems to be properly configured to avoid snafus
    if ($mgmtaddress) == ($::ipaddress_mgmt1) {
      $bmc_network  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\2',) - 1
      $bmc_address  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$',"\\1.${bmc_network}.\\3.\\4",)
      $bmc_username = lookup("bmc_username", String, 'first', '')
      $bmc_password = lookup("bmc_password_${::location}", String, 'first', '')
      if $enable_redfish_http_proxy {
        $http_proxy     = lookup('mgmt__address__proxy', String, 'first', '')
        $http_proxy_url = " --proxy1.0 ${http_proxy}:8888"
      }
      $bmc_idrac_attributes.each |$attribute, $value| {
        if ($attribute == 'IPv4Static.1.Address') and (!$value) {
          $attr_value = $bmc_address
        }
        else {
          $attr_value = $value
        }
        exec { "Set bmc static configuration - ${attribute}":
          command     => "/bin/curl -f -s https://${bmc_address}/redfish/v1/Managers/iDRAC.Embedded.1/Attributes -k -u ${bmc_username}:${bmc_password} ${http_proxy_url} --connect-timeout 20 -X PATCH -H \"Content-Type: application/json\" -d \'{\"Attributes\" : {\"${attribute}\":\"${attr_value}\"}}\' && /bin/touch /etc/.bmc_configured-${attribute}",
          creates     => "/etc/.bmc_configured-${attribute}",
        }
      }
    }
  }
}
