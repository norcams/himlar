#
class profile::openstack::identity (
  $ceilometer_enabled = true,
  $cinder_enabled     = true,
  $glance_enabled     = true,
  $neutron_enabled    = true,
  $nova_enabled       = true,
  $swift_enabled      = true,
  $trove_enabled      = true,
  $roles_extra        = [],
  $manage_firewall    = true,
  $firewall_extras    = {},
  $firewall_extras_a  = {},
  $manage_ssl_cert    = false,
  $manage_openidc     = false,
  $trusted_dashboard  = undef,
  $keystone_config    = {}
) {

  include ::keystone
  include ::keystone::roles::admin
  include ::keystone::endpoint
  include ::keystone::cron::token_flush
  include ::keystone::wsgi::apache

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

  if $manage_ssl_cert {
    include profile::application::sslcert
    Class['Profile::Application::Sslcert'] ~>
    Service[$::keystone::params::service_name]
  }

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

  unless empty($roles_extra) {
    keystone_role { $roles_extra:
      ensure => present
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '228 keystone accept tcp':
      port   => 5000,
      extras => $firewall_extras
    }
    profile::firewall::rule { '229 keystone-admin accept tcp':
      port   => 35357,
      extras => $firewall_extras_a
    }
  }
}
