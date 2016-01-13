class profile::openstack::telemetry {
  include ::ceilometer
  include ::ceilometer::agent::auth
}
