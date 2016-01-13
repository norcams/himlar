class profile::openstack::telemetry::centralagent {
  include profile::openstack::telemetry

  include ::ceilometer::agent::central
}
