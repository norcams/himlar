class profile::openstack::network::vpnaas {
  include profile::openstack::network

  include ::neutron::agents::vpnaas
}
