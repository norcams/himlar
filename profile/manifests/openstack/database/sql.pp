class profile::openstack::database::sql (
  $keystone_enabled = true,
  $glance_enabled   = true,
  $nova_enabled     = true,
  $neutron_enabled  = true,
  $heat_enabled     = false,
  $trove_enabled    = false,
  $cinder_enabled   = false,
  $database         = 'mariadb',
) {

  if $database in ['mariadb', 'postgresql'] {
    include "profile::database::${database}"
  } else {
    fail('invalid database backend selected: choose from mariadb or postgresql')
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

}
