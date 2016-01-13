class profile::openstack::telemetry::collector {
  include profile::openstack::telemetry

  include ::ceilometer::collector
}
