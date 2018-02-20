class profile::openstack::telemetry (
  $pipeline_publishers      = [],
  $manage_gnocchi_resources = false,
  $manage_meters            = false,
  $manage_polling           = false,
  $polling_interval         = '600'
) {

  include ::ceilometer
  include ::ceilometer::config
  include ::ceilometer::client
  include ::ceilometer::keystone::authtoken
  #include ::ceilometer::expirer

  # agents
  include ::ceilometer::agent::auth
  include ::ceilometer::agent::notification
  include ::ceilometer::agent::polling

  # gnocchi
  include ::ceilometer::dispatcher::gnocchi
  include ::gnocchi::client

  if $manage_gnocchi_resources {
    include ::ceilometer::db::sync
    file { '/etc/ceilometer/gnocchi_resources.yaml':
      ensure => file,
      mode   => '0640',
      owner  => 'root',
      group  => 'ceilometer',
      source => "puppet:///modules/${module_name}/openstack/telemetry/gnocchi_resources.yaml",
      notify => Exec['ceilometer-upgrade']
    }
  }

  if $manage_meters {
    file { '/etc/ceilometer/meters.yaml':
      ensure => file,
      mode   => '0640',
      owner  => 'root',
      group  => 'ceilometer',
      source => "puppet:///modules/${module_name}/openstack/telemetry/meters.yaml",
      notify => Service['ceilometer-agent-notification', 'ceilometer-polling']
    }
  }

  if $manage_polling {
    file { '/etc/ceilometer/polling.yaml':
      ensure  => present,
      mode    => '0640',
      owner   => 'root',
      group   => 'ceilometer',
      content => template("${module_name}/openstack/telemetry/polling.yaml.erb"),
      notify  => Service['ceilometer-polling']
    }
  }

  # FIXME This is a hack until pike where this is included in ceilometer::agent::notification
  unless empty($pipeline_publishers) {
    file { '/etc/ceilometer/pipeline.yaml':
      ensure                  => present,
      content                 => template("${module_name}/openstack/telemetry/pipeline.yaml.erb"),
      selinux_ignore_defaults => true,
      mode                    => '0640',
      owner                   => 'root',
      group                   => 'ceilometer',
    }
  }
}
