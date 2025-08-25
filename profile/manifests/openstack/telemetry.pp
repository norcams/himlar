#
class profile::openstack::telemetry (
  $manage_gnocchi_resources = false,
  $manage_meters            = false,
  $manage_polling           = false,
  $polling_interval         = '600'
) {

  include ::keystone::bootstrap
  include ::ceilometer
  include ::ceilometer::config
  include ::ceilometer::logging

  # notification
  include ::ceilometer::agent::service_credentials
  include ::ceilometer::agent::notification

  # polling
  include ::ceilometer::agent::polling

  # gnocchi
  include ::gnocchi::client

  # pipeline
  include ::profile::openstack::telemetry::pipeline

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
