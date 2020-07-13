#
class profile::openstack::compute(
  $manage_az                    = false,
  $manage_telemetry             = false,
  $manage_check_dhcp_lease_file = false
) {
  include ::nova
  include ::nova::config
  include ::nova::placement
  include ::nova::network::neutron
  include ::nova::logging

  if $manage_telemetry {
    include ::profile::openstack::telemetry::polling
    include ::profile::openstack::telemetry::pipeline
  }

  if $manage_az {
    include ::nova::availability_zone
  }

  if $manage_check_dhcp_lease_file {
    file { '/usr/local/bin/check-dhcp-lease-file.sh':
      ensure => present,
      mode   => '0755',
      owner  => 'root',
      source => "puppet:///modules/${module_name}/openstack/compute/check-dhcp-lease-file.sh",
    }
  }
}
