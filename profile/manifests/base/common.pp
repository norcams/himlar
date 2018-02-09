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
  $manage_sudo            = false,
  $manage_authconfig      = false,
  $manage_network         = false,
  $manage_lvm             = false,
  $manage_timezones       = false,
  $manage_keyboard        = false,
  $manage_packages        = false,
  $manage_gems            = false,
  $manage_yumrepo         = false,
  $manage_puppet          = false,
  $manage_cron            = false,
  $manage_fake_ssd        = false,
  $include_physical       = false,
  $include_virtual        = false,
  $classes                = [],
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
  }

  if $manage_cron {
    include ::profile::base::cron
  }

  if $manage_ntp {
    include ::ntp
  }

  if $manage_sudo {
    include ::sudo
    include ::sudo::configs
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

  if $manage_fake_ssd {
    $disk_devices = lookup('profile::storage::fake_ssds', Hash, 'deep', {})
    create_resources('profile::storage::fake_ssd', $disk_devices)
  }

  if $include_physical and ($::is_virtual == false) {
    include ::profile::base::physical
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
