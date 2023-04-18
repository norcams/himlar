# filebeat input for Openstack

define profile::logging::filebeat::input(
  $log            = {},
  $logowner       = {},
  $application    = {},
  $log_type       = {},
  $data_processor = {},
  $tags           = {},
  $input_dir      = "conf.d",
) {

  file { "/etc/filebeat/${input_dir}" :
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '755',
  }

  file { "${name}":
    ensure  => present,
    path    => "/etc/filebeat/${input_dir}/10-${name}",
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    content => template("${module_name}/logging/filebeat/input.yml"),
    notify  => Service['filebeat'],
  }
}

