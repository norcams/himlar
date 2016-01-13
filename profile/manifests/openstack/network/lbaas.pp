class profile::openstack::network::lbaas {
  include profile::openstack::network

  include ::neutron::agents::lbaas
}
