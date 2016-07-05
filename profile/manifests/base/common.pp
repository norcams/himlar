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
  $manage_packages        = true,
  $include_physical       = false,
  $include_virtual        = false,
  $classes                = [],
) {
  include $classes

  if $manage_augeasproviders {
    include ::augeasproviders::instances
  }

  if $manage_accounts {
    include ::accounts::instances
    include ::accounts::root_user
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

  if $include_physical and ($::is_virtual == false) {
    include ::profile::base::physical
  }

  if $include_virtual and ($::is_virtual == true) {
    include ::profile::base::virtual
  }

  if $manage_packages {
    $packages = hiera_hash('profile::base::common::packages', {})
    create_resources('profile::base::package', $packages)
  }
}
