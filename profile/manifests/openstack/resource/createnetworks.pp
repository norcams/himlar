#
# Class: profile::openstack::resource::createnetworks
#
class profile::openstack::resource::createnetworks {

  $networks = lookup('profile::openstack::resource::networks', Hash, 'deep', {})
  $subnets = lookup('profile::openstack::resource::subnets', Hash, 'deep', {})

  create_resources(neutron_network, $networks, { require => Class['neutron']})
  create_resources(neutron_subnet, $subnets, { require => Class['neutron']})

}
