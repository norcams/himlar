class profile::openstack::compute::hypervisor (
  $hypervisor_type = 'libvirt', # Possible value libvirt, vmware, xenserver
  $manage_telemetry = true,
  $manage_firewall = true,
  $firewall_extras = {},
) {
  include ::profile::openstack::compute
  include ::profile::openstack::network
  include ::nova::compute
  include ::nova::compute::neutron
  include ::nova::compute::spice

  if $hypervisor_type in ['libvirt', 'vmware', 'xenserver'] {
    include "::nova::compute::${hypervisor_type}"
  } else {
    fail("Invalid hypervisor_type selected: ${hypervisor_type}")
  }

  if $manage_telemetry {
    include ::profile::openstack::telemetry
    include ::ceilometer::agent::compute
  }

  if $manage_firewall {
    profile::firewall::rule{ '223 vnc accept tcp':
      port   => '5900-5999',
      extras => $firewall_extras,
    }
    profile::firewall::rule{ '224 migration accept tcp':
      port   => ['16509', '49152-49215'],
      extras => $firewall_extras,
    }
  }
}
