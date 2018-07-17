class profile::openstack::database::sql (
  $keystone_enabled = true,
  $glance_enabled   = true,
  $nova_enabled     = true,
  $neutron_enabled  = true,
  $heat_enabled     = false,
  $trove_enabled    = false,
  $cinder_enabled   = false,
  $designate_enabled = false,
  $gnocchi_enabled  = false,
  $ceilometer_enabled = false,
  $database         = 'mariadb',
  $extra_databases  = {},
) {

  if $database in ['mariadb', 'postgresql'] {
    include "profile::database::${database}"
  } else {
    fail('invalid database backend selected: choose from mariadb or postgresql')
  }

  # This replaces password in extra_databases hash with a mysql hashed password
  if $extra_databases {
    $extra_databases.each |String $name, Hash $database| {
      $database_real = merge(delete($database, 'password'), { 'password_hash' => mysql_password($database['password']) })
      create_resources('openstacklib::db::mysql', { $name => $database_real })
    }
  }

  if $keystone_enabled {
    include ::keystone::db::mysql
  }

  if $glance_enabled {
    include ::glance::db::mysql
  }

  if $nova_enabled {
    include ::nova::db::mysql
    include ::nova::db::mysql_api
    include ::nova::db::mysql_placement
  }

  if $cinder_enabled {
    include ::cinder::db::mysql
  }

  if $neutron_enabled {
    include ::neutron::db::mysql
  }

  if $heat_enabled {
    include ::heat::db::mysql
  }

  if $trove_enabled {
    include ::trove::db::mysql
  }

  if $designate_enabled {
    include ::designate::db::mysql
  }

  if $gnocchi_enabled {
    include ::gnocchi::db::mysql
  }

  if $ceilometer_enabled {
    include ::ceilometer::db::mysql
  }

}
