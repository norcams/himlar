#
class profile::openstack::compute(
  $manage_az            = false
) {
  include ::nova
  include ::nova::config
  include ::nova::network::neutron

  if $manage_az {
    include ::nova::availability_zone
  }

}
