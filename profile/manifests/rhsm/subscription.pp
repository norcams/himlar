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
    
  }
}
