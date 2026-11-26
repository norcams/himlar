#
# Manage Free Range Routing for several roles
#
class profile::network::frrouting(
  $enable          = false,
  $manage_service  = false,
  $manage_package  = false,
  $package_name    = 'frr',
  $manage_firewall = false,
  $firewall_extras = {},
) {

  if $manage_package {
    package { 'frrouting':
      name   => $package_name,
      ensure => installed,
    }
  }

  if $enable {
    include ::frrouting
  }

  if $manage_firewall {
    profile::firewall::rule { '011 frr allow bfd':
      proto  => 'udp',
      dport  => ['3784','3785','4784','4785'],
      provider => 'ip6tables',
    }
    profile::firewall::rule { "012 bgp ipv6 - accept tcp to ${name}":
      proto    => 'tcp',
      port     => '179',
      provider => 'ip6tables',
    }
    profile::firewall::rule { "013 - accept vxlan to ${name}":
      proto    => 'udp',
      port     => '4789',
      provider => 'iptables',
    }
  }
}
