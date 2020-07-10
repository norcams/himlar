class profile::rhsm::subscription (
  $manage = false
) {

  if $manage {
    include ::subscription_manager

    $server        = lookup('uio_satellite_server', String, 'first', '')
    $organization  = lookup('uio_satellite_organization', String, 'first', '')
    $activationkey = lookup('uio_satellite_activationkey', String, 'first', '')

    rhsm_config { "$server" }

    rhsm_register { "$server":
      org             => "$organization",
      activationkey   => "$activationkey",
      autosubscribe   => false,
      force           => false,
    }

  }
}
