#
class profile::openstack::compute(
  $manage_az            = false,
  $manage_telemetry     = false
) {
  include ::nova
  include ::nova::config
  include ::nova::network::neutron

  if $manage_telemetry {
    include ::ceilometer::agent::compute
    include ::ceilometer::agent::auth
    include ::ceilometer::keystone::authtoken
  }

  if $manage_az {
    include ::nova::availability_zone
  }

}
