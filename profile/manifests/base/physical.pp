# This class is included from common.pp if is_virtual is false
#
class profile::base::physical (
  $enable_redfish_sensu_check = false,
  $enable_redfish_http_proxy  = undef,
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
}
