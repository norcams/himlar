# Class: profile::openstack::network::createnetworks
#
#
class profile::openstack::network::createnetworks {

  create_resources(neutron_network, hiera('profile::openstack::createnetworks::networks', {}))
  create_resources(neutron_subnet, hiera('profile::openstack::createnetworks::subnets', {}))
}
