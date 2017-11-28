#
class profile::openstack::identity (
  $ceilometer_enabled       = false,
  $cinder_enabled           = false,
  $glance_enabled           = false,
  $neutron_enabled          = false,
  $nova_enabled             = false,
  $swift_enabled            = false,
  $trove_enabled            = false,
  $gnocchi_enabled          = false,
  $roles_extra              = [],
  $manage_firewall          = true,
  $firewall_extras          = {},
  $firewall_extras_a        = {},
  $manage_ssl_cert          = false,
  $manage_openidc           = false,
  $trusted_dashboard        = undef,
  $disable_admin_token_auth = false,
  $manage_token_rotate      = false,
  $keystone_config          = {}
) {

  include ::keystone
  include ::keystone::roles::admin
  include ::keystone::endpoint
  include ::keystone::cron::token_flush # FIXME: remove after change to fernet
  include ::keystone::wsgi::apache

  if $manage_token_rotate {
    include ::keystone::cron::fernet_rotate
  }
  if $disable_admin_token_auth {
    include ::keystone::disable_admin_token_auth
  }
  if $manage_openidc {
    include ::keystone::federation::openidc
    if $trusted_dashboard {
      keystone_config {
        'federation/trusted_dashboard': value => $trusted_dashboard
      }
    }
    keystone_config {
      'federation/remote_id_attribute': value => 'OIDC-iss'
    }
  }

  create_resources('keystone_config', $keystone_config)

  if $swift_enabled {
    include ::swift::keystone::auth
    include ::swift::keystone::dispersion
  }

  if $ceilometer_enabled {
    include ::ceilometer::keystone::auth
  }

  if $nova_enabled {
    include ::nova::keystone::auth
  }

  if $neutron_enabled {
    include ::neutron::keystone::auth
  }

  if $cinder_enabled {
    include ::cinder::keystone::auth
  }

  if $glance_enabled {
    include ::glance::keystone::auth
  }

  if $trove_enabled {
    include ::trove::keystone::auth
  }

  if $gnocchi_enabled {
    include ::gnocchi::keystone::auth
  }

  unless empty($roles_extra) {
    keystone_role { $roles_extra:
      ensure => present
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '228 keystone accept tcp':
      dport  => 5000,
      extras => $firewall_extras
    }
    profile::firewall::rule { '229 keystone-admin accept tcp':
      dport  => 35357,
      extras => $firewall_extras_a
    }
  }
}
