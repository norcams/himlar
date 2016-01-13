class profile::openstack::telemetry::notification {
  include profile::openstack::telemetry

  include ::ceilometer::agent::notification
}
