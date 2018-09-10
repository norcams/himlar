#
class profile::application::report(
  $database_uri,
  $debug              = false,
  $package_url        = false,
  $config_dir         = '/etc/himlar',

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

}
