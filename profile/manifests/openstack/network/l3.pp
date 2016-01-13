class profile::openstack::network::l3(
  $manage_metering = true
) {
  include profile::openstack::network

  include ::neutron::agents::l3

  if $manage_metering {
    include ::neutron::agents::metering
  }
}
