# Simple setup of IP forwarding and NAT with iptables
class profile::network::bgp_router(
  $enable_bird           = false,
  $enable_bird6          = false,
  $bird_template         = undef,
  $bird6_template        = undef,
  $manage_bgp_firewall   = false,
  $manage_bgp_firewall6  = false,
  $router_id             = $::ipaddress_trp1,
) {

  sysctl::value { 'net.ipv4.ip_forward':
  value => 1,
  }
  sysctl::value { 'net.ipv6.conf.all.forwarding':
  value => 1,
  }
  if $enable_bird {
    package { 'bird':
      ensure   => installed
    }
    file { '/etc/bird.conf':
      ensure   => file,
      content  => template("${module_name}/bird/${bird_template}"),
      notify   => Service['bird']
    }
    service { 'bird':
      ensure   => running,
      enable   => true,
      require  => Package['bird']
    }
  }
  if $enable_bird6 {
    package { 'bird6':
      ensure   => installed
    }
    file { '/etc/bird6.conf':
      ensure   => file,
      content  => template("${module_name}/bird/${bird6_template}"),
      notify   => Service['bird6']
    }
    service { 'bird6':
      ensure   => running,
      enable   => true,
      require  => Package['bird6']
    }
  }
  if $manage_bgp_firewall {
    profile::firewall::rule { '912 bgp allow bfd':
      proto  => 'udp',
      port   => ['3784','3785','4784','4785'],
    }
    profile::firewall::rule { "010 bgp - accept tcp to ${name}":
      proto   => 'tcp',
      port    => '179',
      iniface => $::ipaddress_trp1,
    }
  }
  if $manage_bgp_firewall6 {
    profile::firewall::rule { '912 bgp allow bfd ipv6':
      proto    => 'udp',
      port     => ['3784','3785','4784','4785'],
      provider => 'ip6tables',
    }
    profile::firewall::rule { "010 bgp ipv6 - accept tcp to ${name}":
      proto    => 'tcp',
      port     => '179',
      provider => 'ip6tables',
      iniface  => $::ipaddress6_trp1,
    }
  }
}
