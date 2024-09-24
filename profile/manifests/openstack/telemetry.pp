#
class profile::openstack::telemetry (
  $manage_gnocchi_resources = false,
  $manage_meters            = false,
  $manage_polling           = false,
  $polling_interval         = '600'
) {

  include ::ceilometer
  include ::ceilometer::config
  include ::ceilometer::keystone::authtoken
  include ::ceilometer::logging
  #include ::ceilometer::expirer

  # notification
  include ::ceilometer::agent::service_credentials
  include ::ceilometer::agent::notification

  # gnocchi
  include ::gnocchi::client

  # pipeline hack
  include ::profile::openstack::telemetry::pipeline

  # polling
  include ::profile::openstack::telemetry::polling

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
    file { '/etc/ceilometer/meters.d/meters.yaml':
      ensure => file,
      mode   => '0640',
      owner  => 'root',
      group  => 'ceilometer',
      source => "puppet:///modules/${module_name}/openstack/telemetry/meters.d/meters.yaml",
      notify => Service['ceilometer-agent-notification', 'ceilometer-polling']
    }
    # Remove old file
    file { '/etc/ceilometer/meters.yaml':
      ensure => absent,
    }
  }

}
