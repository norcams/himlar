class profile::openstack::compute::hypervisor (
  $hypervisor_type = 'libvirt', # Possible value libvirt, vmware, xenserver
  $manage_libvirt_rbd = false,
  $manage_telemetry = true,
  $manage_firewall = true,
  $modular_libvirt = false,
  $enable_dhcp_agent_check = false,
  $remove_default_libvirt_network = false,
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

  if $modular_libvirt {
    include ::nova::compute::libvirt::services
    include ::nova::compute::libvirt::virtproxyd
    file_line { 'disable auth for virtproxyd tcp socket':
      path   => '/etc/libvirt/virtproxyd.conf',
      line   => 'auth_tcp = "none"',
      match  => '^#auth_tcp = "sasl"',
      before => Service['virtproxyd-tcp.socket'],
      notify => Service['virtproxyd-tcp.socket']
    }
    file_line { 'disable tls for virtproxyd tcp socket':
      path   => '/etc/libvirt/virtproxyd.conf',
      line   => 'listen_tls = 0',
      match  => '^#listen_tls = 0',
      before => Service['virtproxyd-tcp.socket'],
      notify => Service['virtproxyd-tcp.socket']
    }
    file_line { 'enable tcp for virtproxyd tcp socket':
      path   => '/etc/libvirt/virtproxyd.conf',
      line   => 'listen_tcp = 1',
      match  => '^#listen_tcp = 1',
      before => Service['virtproxyd-tcp.socket'],
      notify => Service['virtproxyd-tcp.socket']
    }
    service { 'virtproxyd-tcp.socket':
      ensure => running,
      enable => true
    }
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

  if $remove_default_libvirt_network {
    exec { 'virsh-net-destroy-default':
      command => 'virsh net-destroy default',
      path    => '/bin:/usr/bin',
      onlyif  => "virsh -q net-list --all | grep -Eq '^\s*default\\s+active'",
    }
    exec { 'virsh-net-undefine-default':
      command => 'virsh net-undefine default',
      path    => '/bin:/usr/bin',
      onlyif  => "virsh -q net-list --all | grep -Eq '^\s*default\\s+inactive'",
      require => Exec['virsh-net-destroy-default'],
    }
    file { [ '/etc/libvirt/qemu/networks/default.xml', '/etc/libvirt/qemu/networks/autostart/default.xml' ]:
      ensure  => absent,
      require => Exec['virsh-net-undefine-default'],
    }
  }

  if $enable_dhcp_agent_check {

    # the new template only checks for missing dnsmasq
    if Integer($facts['os']['release']['major']) == 8 {
      $dhcp_agent_check_template = 'calico_dhcp_agent_check.sh.erb'
    } else {
      $dhcp_agent_check_template = 'calico_dhcp_agent_check_new.sh.erb'
    }

    file { 'calico_dhcp_agent_check.sh':
      ensure  => file,
      path    => '/usr/local/bin/calico_dhcp_agent_check.sh',
      content => template("${module_name}/monitoring/sensu/${dhcp_agent_check_template}"),
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
