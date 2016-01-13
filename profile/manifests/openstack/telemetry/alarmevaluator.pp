class profile::openstack::telemetry::alarmevaluator {
  include profile::openstack::telemetry

  include ::ceilometer::alarm::evaluator
}
