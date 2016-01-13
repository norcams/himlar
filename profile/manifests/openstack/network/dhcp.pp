class profile::openstack::network::dhcp {
  include profile::openstack::network

  include ::neutron::agents::dhcp
}
