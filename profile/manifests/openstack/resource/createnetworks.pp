# Class: profile::openstack::resource::createnetworks
#
#
class profile::openstack::resource::createnetworks {

  create_resources(neutron_network, hiera_hash('profile::openstack::resource::networks', {}))
  create_resources(neutron_subnet, hiera_hash('profile::openstack::resource::subnets', {}))
}
