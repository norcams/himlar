# filebeat client for Openstack

# This creates a simple filebeat setup with log inputs
# and logstash outputs

class profile::logging::filebeat(
  $manage_filebeat = false,
  $inputs          = {},
  $outputs         = {},
  $config_dir      = "/etc/filebeat",
  $config_file     = "filebeat.yml",
) {

  if $manage_filebeat {
      create_resources( 'profile::logging::filebeat::input', $inputs )

      file { "$config_dir" :
        ensure => 'directory',
      }

      ->

      file { "${config_file}" :
        ensure  => present,
        path    => "${config_dir}/${config_file}",
        owner   => 'root',
        group   => 'root',
        mode    => '644',
        content => template("${module_name}/logging/filebeat/filebeat.yml"),
        notify  => Service['filebeat'],
     }

     service { 'filebeat':
       ensure   => running,
       enable   => true,
       require  => Package['filebeat']
    }
  }

}

