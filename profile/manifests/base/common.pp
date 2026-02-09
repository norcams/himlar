#
class profile::base::common (
  $manage_augeasproviders = false,
  $manage_epel            = false,
  $manage_accounts        = false,
  $manage_logging         = undef,
  $manage_monitoring      = undef,
  $manage_smtp            = undef,
  $manage_ssh             = false,
  $manage_ntp             = false,
  $manage_chrony          = false,
  $manage_sudo            = false,
  $manage_authconfig      = false,
  $manage_network         = false,
  $manage_lvm             = false,
  $manage_timezones       = false,
  $manage_keyboard        = false,
  $manage_packages        = false,
  $manage_gems            = false,
  $manage_yumrepo         = false,
  $manage_sysctl          = false,
  $manage_puppet          = false,
  $manage_cron            = false,
  $manage_fake_ssd        = false,
  $manage_multipath       = false,
  $manage_vm_swappiness   = false,
  $disable_firewalld      = false,
  $multipath_hash_policy  = 1,         # Layer 4 hash policy (source port, dest port, source addr, dest addr, protocol)
  $vm_swappiness          = '10',
  $include_physical       = false,
  $include_virtual        = false,
  $extraswap              = false,
  $extraswap_sizegb       = '10',
  $extraswap_fileloc      = '/var/lib/nova/instances/swapfile',
  $classes                = [],
  $users_ssh_options      = {},
) {
  # Can be used to include custom classes (mostly for testing)
  include $classes

  # Is this still needed? Non-compatible with Puppet 4
  # if $manage_augeasproviders {
  #   include ::augeasproviders::instances
  # }

  if $manage_accounts {
    include ::accounts::instances
    include ::accounts::root_user
    if $::osfamily == 'FreeBSD' {
      group { 'users':
        ensure => present,
        gid    => '100',
      }
    }
  }

  if $manage_epel {
    include ::epel
  }

  if $manage_logging {
    include "::profile::logging::${manage_logging}::agent"
  }

  if $manage_monitoring {
    include "::profile::monitoring::${manage_monitoring}::agent"
  }

  if $manage_smtp {
    include "::profile::mailserver::${manage_smtp}"
  }

  if $manage_ssh {
    include ::ssh::client
    include ::ssh::server

    create_resources('ssh::client::config::user', $users_ssh_options)
  }

  if $::operatingsystem == 'AlmaLinux' and $disable_firewalld {
    service { 'firewalld':
      ensure => stopped,
      enable => false
    }
  }

  if $manage_cron {
    include ::profile::base::cron
  }

  if $manage_chrony {
    include ::chrony

    service { 'ntpd':
      ensure => stopped,
      enable => false
    }
    # Chrony on Cumulus Linux must run in the mgmt VRF
    case $::operatingsystem {
      'CumulusLinux': {
        file { '/etc/systemd/system/chrony@.service':
          ensure => 'present',
          source => '/lib/systemd/system/chrony.service',
        }
        service { 'chrony':
          ensure => stopped,
          enable => false
        }
      }
      default: {
      }
    }
  }

  if $manage_ntp {
    include ::ntp

    service { 'chronyd':
      ensure => stopped,
      enable => false
    }
  }

  if $manage_sudo {
    include ::sudo
  }

  if $manage_authconfig {
    include ::authconfig
  }

  if $manage_network {
    include ::profile::base::network
  }

  if $manage_lvm {
    include ::profile::base::lvm
  }

  if $manage_timezones {
    include timezone
  }

  if $manage_keyboard {
    include keyboard
  }

  if ($extraswap) and ($::runmode != 'kickstart') {
    exec { 'create_swapfile':
      command => "dd if=/dev/zero of=${extraswap_fileloc} bs=1M count=$((${extraswap_sizegb}*1024)) && sudo chmod 600 ${extraswap_fileloc}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => ["test -f ${extraswap_fileloc}"],
      require => Class['profile::base::lvm'],
    } ~>
    exec { 'activate_extraswap':
      command     => "mkswap ${extraswap_fileloc} && swapon ${extraswap_fileloc}",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      refreshonly => true,
    } ~>
    file_line { 'extraswap':
      path  => '/etc/fstab',
      line  => "${extraswap_fileloc} swap swap defaults 0 0",
      match => "^${extraswap_fileloc}",
    }
  }

  if $manage_fake_ssd {
    $disk_devices = lookup('profile::storage::fake_ssds', Hash, 'deep', {})
    create_resources('profile::storage::fake_ssd', $disk_devices)
  }

  if $manage_multipath {
    sysctl::value {
      'net.ipv4.fib_multipath_hash_policy':
        value => $multipath_hash_policy,
    } ~>
    sysctl::value {
      'net.ipv6.fib_multipath_hash_policy':
        value => $multipath_hash_policy,
    }
  }

  if $manage_vm_swappiness {
    sysctl::value { 'vm.swappiness':
      value => $vm_swappiness,
    }
  }

  if $manage_sysctl {
    $sysctl_values = lookup('profile::base::common::sysctl_values', Hash, 'deep', {})
    create_resources ('sysctl::value', $sysctl_values)
  }

  if $include_physical and ($::is_virtual == false) {
    include ::profile::base::physical
    if fact('manufacturer') == 'Dell Inc.' {
      include ::profile::base::dell
    }
  }

  if $include_virtual and ($::is_virtual == true) {
    include ::profile::base::virtual
  }

  if $manage_packages {
    $packages = lookup('profile::base::common::packages', Hash, 'deep', {})
    create_resources('profile::base::package', $packages)
  }

  if $manage_gems {
    $gems = lookup('profile::base::common::gems', Hash, 'deep', {})
    create_resources('profile::base::gem', $gems)
  }

  if $manage_yumrepo {
    include ::profile::base::yumrepo
    # Use only ipv4 for resolve when managing yum repo
    file_line { 'yum_resolv':
      path  => '/etc/yum.conf',
      line  => 'ip_resolve=4',
      match => '^ip_resolve='
    }
  }

  if $manage_puppet {
    include ::puppet
  }
}
