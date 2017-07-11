#
class profile::highavailability::loadbalancing::haproxy (
  $manage_haproxy          = false,
  $manage_firewall         = false,
  $allow_from_network      = undef,
  $firewall_extras         = {},
  $haproxy_listens         = {},
  $haproxy_frontends       = {},
  $haproxy_backends        = {},
  $haproxy_balancermembers = {},
  $haproxy_userlists       = {},
  $haproxy_peers           = {},
  $haproxy_mapfile         = {}
) {

  if $manage_haproxy {

    include ::haproxy

    Haproxy::Listen {
      collect_exported => false
    }

    Haproxy::Backend {
      collect_exported => false
    }

    create_resources('haproxy::listen', $haproxy_listens)
    create_resources('haproxy::backend', $haproxy_backends)
    create_resources('haproxy::frontend', $haproxy_frontends)
    create_resources('haproxy::balancermember', $haproxy_balancermembers)
    create_resources('haproxy::userlist', $haproxy_userlists)
    create_resources('haproxy::mapfile', $haproxy_mapfile)
    create_resources('haproxy::peer', $haproxy_peers)

    file { '/etc/haproxy/sorry.http':
      ensure => present,
      source => "puppet:///modules/${module_name}/loadbalancing/haproxy.sorry.http",
      notify => Service['haproxy']
    }

    file { '/root/watch-status.sh':
      ensure  => present,
      mode    => '0755',
      content => "watch 'echo \"show stat\" | nc -U /var/lib/haproxy/stats | cut -d \",\" -f 1,2,5-11,18,24,27,30,36,50,37,56,57,62 | column -s, -t'"
  }

  }

  if $manage_firewall {
    $hiera_allow_from_network = hiera_array('allow_from_network', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }
    profile::firewall::rule { '450 haproxy accept tcp':
      proto       => 'tcp',
      destination => $::ipaddress_public1,
      source      => $source,
      extras      => $firewall_extras,
    }
  }

}
