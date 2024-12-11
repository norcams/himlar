# manage /etc/ceilometer/polling.yaml until pike
class profile::openstack::telemetry::polling (
  $manage_polling           = false,
  $polling_interval         = '600'
) {

  include ::ceilometer
  include ::ceilometer::config
  include ::ceilometer::agent::service_credentials
  include ::ceilometer::agent::polling

}
