class profile::openstack::compute {
  include ::nova
  include ::nova::network::neutron
}
