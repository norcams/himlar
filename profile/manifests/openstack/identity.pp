#
class profile::openstack::identity (
  $ceilometer_enabled       = false,
  $cinder_enabled           = false,
  $glance_enabled           = false,
  $neutron_enabled          = false,
  $nova_enabled             = false,
  $swift_enabled            = false,
  $trove_enabled            = false,
  $designate_enabled        = false,
  $gnocchi_enabled          = false,
  $roles_extra              = [],
  $manage_firewall          = true,
  $firewall_extras          = {},
  $firewall_extras_a        = {},
  $manage_ssl_cert          = false,
  $manage_openidc           = false,
  $trusted_dashboard        = undef,
  $disable_admin_token_auth = false,
  $token_rotation_sync      = false,
  $manage_token_rotate      = false,
  $token_db                 = 'token_keys',
  $keystone_config          = {},
  $cron_master              = {},
  $cron_slave               = {},
  $fernet_active_keys       = 3,
  $credential_active_keys   = 2,
  $fernet_key_repo          = '',
  $credential_key_repo      = '',
  $dbpw                     = '',
  $db_host                  = '',
  $gpg_receiver             = '',
  $manage_policy            = false,
) {

  include ::keystone
  include ::keystone::config
  include ::keystone::roles::admin
  include ::keystone::endpoint
  include ::keystone::wsgi::apache

  # this system is part of a master/slave token cluster?
  if $token_rotation_sync {

    # this system is the token master?
    if $manage_token_rotate {
      # cron job to rotate the fernet tokens
      include ::keystone::cron::fernet_rotate

      # cron jobs related to master token handling
      create_resources('cron', $cron_master)

    } else  {
      # cron job to retrieve keys from database
      create_resources('cron', $cron_slave)
    }
    file { '/usr/local/sbin/token_dist.sh':
      ensure  => present,
      mode    => '0750',
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/openstack/keystone/token_dist.erb")
    }

  }

  if $manage_policy {
    include ::keystone::policy
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
    include ::nova::keystone::auth_placement
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

  if $designate_enabled {
    include ::designate::keystone::auth
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
