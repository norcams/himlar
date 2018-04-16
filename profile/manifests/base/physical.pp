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

  # Add firmware repo on Dell machines FIXME
  if fact('manufacturer') == 'Dell Inc.' {
    yumrepo { 'dell-system-update_independent':
      ensure   => present,
      baseurl  => 'http://linux.dell.com/repo/hardware/dsu/os_independent/',
      gpgcheck => 1,
      gpgkey   => 'http://linux.dell.com/repo/hardware/dsu/public.key',
      exclude  => 'dell-system-update*.i386',
      enabled  => 1
    }
    yumrepo { 'dell-system-update_dependent':
      ensure     => present,
      mirrorlist => 'http://linux.dell.com/repo/hardware/dsu/mirrors.cgi?osname=el$releasever&basearch=$basearch&native=1',
      gpgcheck   => 1,
      gpgkey     => 'http://linux.dell.com/repo/hardware/dsu/public.key',
      enabled    => 1
    }
    package { 'dell-system-update':
      ensure => installed
    }
  }

}
