# This class is included from common.pp if is_virtual is false
#
class profile::base::physical
{
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

}
