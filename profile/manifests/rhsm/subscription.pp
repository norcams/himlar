class profile::rhsm::subscription (
  $manage = false
) {

  if $manage {

    $server        = lookup('uio_satellite_server', String, 'first', '')
    $organization  = lookup('uio_satellite_organization', String, 'first', '')
    $activationkey = lookup('uio_satellite_activationkey', String, 'first', '')

    class { 'subscription_manager':
      server_hostname => $server,
      org             => $organization,
      activationkey   => $activationkey,
      autosubscribe   => false,
      service_name    => 'rhsmcertd',
      force           => true,
    }

    exec { "disable_auto_enable_yum_plugins":
      command => '/usr/sbin/subscription-manager config --rhsm.auto_enable_yum_plugins=0',
      unless  => "/usr/bin/grep -q '^auto_enable_yum_plugins = 0' /etc/rhsm/rhsm.conf"
  }

}
