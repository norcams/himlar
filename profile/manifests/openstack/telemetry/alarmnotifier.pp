class profile::openstack::telemetry::alarmnotifier {
  include profile::openstack::telemetry

  include ::ceilometer::alarm::notifier
}
