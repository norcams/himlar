class profile::openstack::database::sql (
  $keystone_enabled = true,
  $glance_enabled   = true,
  $nova_enabled     = true,
  $neutron_enabled  = true,
  $heat_enabled     = false,
  $trove_enabled    = false,
  $cinder_enabled   = false,
  $gnocchi_enabled  = false,
  $ceilometer_enabled = false,
  $create_cell0     = false,
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

    #FIXME nova puppet module creates database in ocata
    if $create_cell0 {

      $addr1 = lookup('netcfg_trp_netpart', String, 'first', '')
      $addr2 = lookup('domain_trp', String, 'first', '')

      mysql_database { 'nova_cell0':
        ensure    => present,
        charset   => 'utf8',
      }
      mysql_grant { "nova@${addr1}.%/*.*":
        ensure    => present,
        privileges => ['ALL'],
        table    => '*.*',
        user     => "nova@${addr1}.%",
      }
      # mysql_grant { "nova@compute.${addr2}/*.*":
      #   ensure    => present,
      #   privileges => ['ALL'],
      #   table    => '*.*',
      #   user     => "nova@compute.${addr2}",
      #}
    }
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

  if $gnocchi_enabled {
    include ::gnocchi::db::mysql
  }

  if $ceilometer_enabled {
    include ::ceilometer::db::mysql
  }

}
