#
class profile::application::report(
  $database_uri,
  $debug              = false,
  $package_url        = false,
  $config_dir         = '/etc/himlar',
  $install_dir        = '/opt/report-app',
  $db_sync            = false
) {

  if $package_url {
    package { 'report-app':
      ensure   => 'present',
      provider => 'rpm',
      source   => $package_url,
      notify   => Class['apache::service']
    }
  }

  file { $config_dir:
    ensure => directory
  } ->
  file { "${config_dir}/production.cfg":
    ensure  => file,
    owner   => 'root',
    mode    => '0644',
    content => template("${module_name}/application/report/production.cfg.erb"),
    notify  => Class['apache::service']
  }

  if $db_sync {
    exec { 'create api tables in db':
      command => "${install_dir}/bin/python ${install_dir}/db-manage.py create api && touch ${install_dir}/.api.dbsync",
      require => File["${config_dir}/production.cfg"],
      creates => "${install_dir}/.api.dbsync"
    }
    exec { 'create oauth tables in db':
      command => "${install_dir}/bin/python ${install_dir}/db-manage.py create oauth && touch ${install_dir}/.oauth.dbsync",
      require => File["${config_dir}/production.cfg"],
      creates => "${install_dir}/.oauth.dbsync"

    }
  }

}
