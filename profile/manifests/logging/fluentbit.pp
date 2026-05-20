#
class profile::logging::fluentbit(
  $manage_fluentbit         = false,
  $manage_dns_data          = false,
  $manage_data_dir          = false,
  $manage_parsers_file      = false,
  $config_dir               = '/etc/fluent-bit',
  $config_file              = 'fluent-bit.conf',
  $config_file_uio_dns      = 'UIO_input_tail-dns-bind9-hostmaster.conf',
  $config_file_uio_filter   = 'UIO_filter-sysinfo-all.conf',
  $config_file_uio_output   = 'UIO_PROD_output-dataops-http-receiver-5000-uio-logs.conf',
) {


  if $manage_fluentbit  {
    class { 'fluentbit': manage_parsers_file => $manage_parsers_file,
                         manage_data_dir     => $manage_data_dir,
    }

    $service_name = $fluentbit::service_name

    file { '/var/log/fluent-bit' :
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file { '/var/lib/fluent-bit' :
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
#    file { '/var/lib/fluent-bit/storage' :
#      ensure => 'directory',
#      owner  => 'root',
#      group  => 'root',
#      mode   => '0755',
#    }


    # copy all static files (relevant ones are enabled further down)
    file { "$config_dir/fluent-bit.conf.d" :
      ensure => 'directory',
      source => "puppet:///modules/${module_name}/logging/fluentbit/fluent-bit.conf.d",
      recurse=> true,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      notify => Service["$service_name"],
    }
    # ... and create remaining ones from templates
    file { "$config_dir/fluent-bit.conf.d/$config_file_uio_output" :
      content=> template("${module_name}/logging/fluentbit/${config_file_uio_output}.erb"),
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      notify => Service["$service_name"],
    }

    file { "$config_dir/pipelines" :
      ensure => 'directory',
      source => "puppet:///modules/${module_name}/logging/fluentbit/pipelines",
      recurse=> true,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      notify => Service["$service_name"],
    }


    # Which configuration to enable on DNS related roles

    if $manage_dns_data {
      file { "${config_dir}/fluent-bit.conf.d/${config_file_uio_dns}_enable" :
        ensure => 'link',
        target => "$config_file_uio_dns",
        notify => Service["$service_name"],
      }
      file { "${config_dir}/fluent-bit.conf.d/${config_file_uio_filter}_enable" :
        ensure => 'link',
        target => "$config_file_uio_filter",
        notify => Service["$service_name"],
      }
      file { "${config_dir}/fluent-bit.conf.d/${config_file_uio_output}_enable" :
        ensure => 'link',
        target => "$config_file_uio_output",
        notify => Service["$service_name"],
      }
    }
  }

}
