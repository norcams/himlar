class profile::openstack::compute::hypervisor (
  $hypervisor_type = 'libvirt', # Possible value libvirt, vmware, xenserver
  $manage_libvirt_rbd = false,
  $manage_telemetry = true,
  $manage_firewall = true,
  $fix_snapshot_loc = false, # FIXME - Should probably be removed for newton release
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

  if $hypervisor_type in ['libvirt'] {
    include ::nova::migration::libvirt
  }

  if $manage_libvirt_rbd {
    include ::nova::compute::rbd
  }

  if $manage_telemetry {
    include ::profile::openstack::telemetry
    include ::ceilometer::agent::compute
  }

  if $manage_firewall {
    profile::firewall::rule{ '223 vnc accept tcp':
      dport  => '5900-5999',
      extras => $firewall_extras,
    }
    profile::firewall::rule{ '224 migration accept tcp':
      dport  => '49152-49215',
      extras => $firewall_extras,
      source => "${::network_live1}/${::netmask_live1}",
    }
    profile::firewall::rule{ '224-1 migration accept tcp':
      dport  => '16509',
      extras => $firewall_extras,
      source => "${::network_live1}/${::netmask_live1}",
    }
  }

  # FIXME - Should probably be removed for newton release
  if $fix_snapshot_loc {
    file { '/var/lib/nova/instances/save':
      ensure => 'directory',
    } ->
    file { '/var/lib/libvirt/qemu/save':
      ensure => 'link',
      target => '/var/lib/nova/instances/save',
      force  => true,
    }
  }
}
