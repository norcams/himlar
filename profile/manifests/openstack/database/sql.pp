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
  $charset           = 'utf8mb3',               # FIXME: May be removed when puppet-mysql is at >= 16.0.0
  $collate           = 'utf8mb3_general_ci',    # FIXME: May be removed when puppet-mysql is at >= 16.0.0
) {

  if $database in ['mariadb', 'postgresql'] {
    include "profile::database::${database}"
  } else {
    fail('invalid database backend selected: choose from mariadb or postgresql')
  }

  # This replaces password in extra_databases hash with a mysql hashed password
  if $extra_databases {
    $extra_databases.each |String $name, Hash $database| {
      $database_real = merge(delete($database, 'password'), { 'password' => mysql_password($database['password']) })
      create_resources('openstacklib::db::mysql', $name => $database_real, { 'charset' => $charset, 'collate' => $collate })
    }
  }

  if $keystone_enabled {
    class { '::keystone::db::mysql':
             charset => $charset,               # FIXME: May be removed when puppet-mysql is at >= 16.0.0
             collate => $collate                # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $glance_enabled {
    class { '::glance::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $nova_enabled {
    class { '::nova::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
    class { '::nova::db::mysql_api':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $placement_enabled {
    class { '::placement::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $cinder_enabled {
    class { '::cinder::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $neutron_enabled {
    class { '::neutron::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $heat_enabled {
    class { '::heat::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $trove_enabled {
    class { '::trove::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $designate_enabled {
    class { '::designate::db::mysql':
             charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
             collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
    }
  }

  if $gnocchi_enabled {
     class { '::gnocchi::db::mysql':
              charset => $charset,                # FIXME: remove when puppet-mysql is at => 16.0.0
              collate => $collate                 # FIXME: remove when puppet-mysql is at => 16.0.0
     }
  }

}
