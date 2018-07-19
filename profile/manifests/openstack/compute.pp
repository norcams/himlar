#
class profile::openstack::compute(
  $manage_az            = false,
  $manage_telemetry     = false
) {
  include ::nova
  include ::nova::config
  include ::nova::placement
  include ::nova::network::neutron

  if $manage_telemetry {
    include ::profile::openstack::telemetry::polling
    include ::profile::openstack::telemetry::pipeline
  }

  if $manage_az {
    include ::nova::availability_zone
  }

}
