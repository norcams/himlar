# FIXME: only used for placement upgrade in stein

class profile::openstack::compute::placement() {

  $placement_pw = lookup('placement::db::mysql::password', String, 'first', 'MISSING')
  $nova_placement_pw = lookup('nova::db::mysql_placement::password', String, 'first', 'MISSING')
  $db_host = lookup('service__address__db_regional', String, 'first', 'MISSING')

  file { '/root/migrate-db.rc':
    ensure  => file,
    content => template("${module_name}/openstack/compute/migrate-db.rc.erb"),
    mode    => '0600'
  }

}
