class profile::openstack::compute {
  include ::nova
  include ::nova::config
  include ::nova::network::neutron
}
