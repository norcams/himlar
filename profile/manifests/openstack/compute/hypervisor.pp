class profile::openstack::compute::hypervisor (
  $hypervisor_type = 'libvirt', # Possible value libvirt, vmware, xenserver
  $manage_libvirt_rbd = false,
  $manage_telemetry = true,
  $manage_firewall = true,
  $enable_dhcp_agent_check = false,
  $sysctl_fixes = false,
  $net_ipv4_route_max_size = '2147483647',
  $net_ipv6_route_max_size = '2147483647',
  $net_ipv4_route_gc_thresh = '-1',
  $net_ipv6_route_gc_thresh = '-1',
  $fix_snapshot_loc = false, # FIXME - Should probably be removed for newton release
  $firewall_extras = {},
) {
  include ::profile::openstack::compute
  include ::profile::openstack::network
  include ::nova::compute
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
      dport  => '5900-6099',
      extras => $firewall_extras,
    }
    profile::firewall::rule{ '224 migration accept tcp':
      dport  => '49152-49261',
      extras => $firewall_extras,
      source => "${::network_live1}/${::netmask_live1}",
    }
    profile::firewall::rule{ '224-1 migration accept tcp':
      dport  => '16509',
      extras => $firewall_extras,
      source => "${::network_live1}/${::netmask_live1}",
    }
  }

  # Defaults in el8 are too small for ipv6
  if $sysctl_fixes {
    sysctl::value { "net.ipv4.route.max_size":
      value => $net_ipv4_route_max_size,
    }
    sysctl::value { "net.ipv6.route.max_size":
      value => $net_ipv6_route_max_size,
    }
    sysctl::value { "net.ipv4.route.gc_thresh":
      value => $net_ipv4_route_gc_thresh,
    }
    sysctl::value { "net.ipv6.route.gc_thresh":
      value => $net_ipv6_route_gc_thresh,
    }
  }

  if $enable_dhcp_agent_check {
    file { 'calico_dhcp_agent_check.sh':
      ensure  => file,
      path    => '/usr/local/bin/calico_dhcp_agent_check.sh',
      content => template("${module_name}/monitoring/sensu/calico_dhcp_agent_check.sh.erb"),
      mode    => '0755',
    }
  }

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
