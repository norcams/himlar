class profile::openstack::database::sql (
  $keystone_enabled  = false,
  $glance_enabled    = false,
  $nova_enabled      = false,
  $neutron_enabled   = false,
  $heat_enabled      = false,
  $trove_enabled     = false,
  $cinder_enabled    = false,
  $designate_enabled = false,
  $gnocchi_enabled   = false,
  $placement_enabled = false,
  $database          = 'mariadb',
  $extra_databases   = {},
  $charset           = 'utf8mb3',
  $collate           = 'utf8mb3_general_ci',
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
      create_resources('openstacklib::db::mysql', $name => $database_real, { 'charset' => $charset, 'collate' => $collate })
    }
  }

  if $keystone_enabled {
    class { '::keystone::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $glance_enabled {
    class { '::glance::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $nova_enabled {
    class { '::nova::db::mysql':
             charset => $charset,
             collate => $collate
    }
    class { '::nova::db::mysql_api':
             charset => $charset,
             collate => $collate
    }
  }

  if $placement_enabled {
    class { '::placement::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $cinder_enabled {
    class { '::cinder::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $neutron_enabled {
    class { '::neutron::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $heat_enabled {
    class { '::heat::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $trove_enabled {
    class { '::trove::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $designate_enabled {
    class { '::designate::db::mysql':
             charset => $charset,
             collate => $collate
    }
  }

  if $gnocchi_enabled {
     class { '::gnocchi::db::mysql':
              charset => $charset,
              collate => $collate
     }
  }

}
