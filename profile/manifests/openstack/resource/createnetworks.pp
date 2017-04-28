#
# Class: profile::openstack::resource::createnetworks
#
class profile::openstack::resource::createnetworks {

  $networks = hiera_hash('profile::openstack::resource::networks', {})
  $subnets = hiera_hash('profile::openstack::resource::subnets', {})
  create_resources(neutron_network, $networks, { require => Class['neutron']})
  create_resources(neutron_subnet, { require => Class['neutron']})

}
