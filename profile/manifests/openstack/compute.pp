#
class profile::openstack::compute(
  $manage_az                    = false,
  $manage_telemetry             = false,
  $manage_nova_config           = false,
  $manage_check_dhcp_lease_file = false
) {
  include ::nova
  include ::nova::db
  include ::nova::config
  include ::nova::network::neutron
  include ::nova::cinder
  include ::nova::logging
  include ::nova::placement

  if $manage_telemetry {
    include ::profile::openstack::telemetry::polling
    include ::profile::openstack::telemetry::pipeline
  }

  if $manage_az {
    include ::nova::availability_zone
  }

  if $manage_nova_config {
    $default_nova_config = lookup('profile::openstack::compute::default_nova_config', Hash, 'deep', {})
    create_resources('nova_config', $default_nova_config)
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
