# manage /etc/ceilometer/polling.yaml until pike
class profile::openstack::telemetry::polling (
  $manage_polling           = false,
  $polling_interval         = '600'
) {

  include ::ceilometer
  include ::ceilometer::config
  include ::ceilometer::agent::service_credentials
  include ::ceilometer::agent::polling

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

}
