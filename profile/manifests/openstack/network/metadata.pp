class profile::openstack::network::metadata {
  include profile::openstack::network

  include ::neutron::agents::metadata
}
