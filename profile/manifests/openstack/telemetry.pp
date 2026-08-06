#
class profile::openstack::telemetry (
#  $manage_meters            = false,
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

  # cache
  include ::ceilometer::cache

  # gnocchi
  include ::gnocchi::client

#  if $manage_meters {
#    file { '/etc/ceilometer/meters.d/meters.yaml':
#      ensure => file,
#      mode   => '0640',
#      owner  => 'root',
#      group  => 'ceilometer',
#      source => "puppet:///modules/${module_name}/openstack/telemetry/meters.d/meters.yaml",
#      notify => Service['ceilometer-agent-notification', 'ceilometer-polling']
#    }
#    # Remove old file
#    file { '/etc/ceilometer/meters.yaml':
#      ensure => absent,
#    }
#  }

}
