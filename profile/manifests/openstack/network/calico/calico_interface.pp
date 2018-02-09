# Define a wrapper to avoid duplicating config per interface

define profile::openstack::network::calico::calico_interface() {
  $iniface_name = regsubst($name, '_', '.')
  profile::firewall::rule { "010 bird bgp - accept tcp to ${name}":
    proto   => 'tcp',
    dport   => '179',
    iniface => $iniface_name,
    extras  => $profile::openstack::network::calico::firewall_extras,
  }
  profile::firewall::rule { "010 bird bgp - accept tcp to ${name}-ipv6":
    proto    => 'tcp',
    dport    => '179',
    iniface  => $iniface_name,
    extras   => $profile::openstack::network::calico::firewall_extras,
    provider => 'ip6tables',
  }
}
