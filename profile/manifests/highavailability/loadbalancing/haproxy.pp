#
class profile::highavailability::loadbalancing::haproxy (
  $manage_haproxy          = false,
  $manage_firewall         = false,
  $firewall_extras         = {},
  $haproxy_listens         = {},
  $haproxy_frontends       = {},
  $haproxy_backends        = {},
  $haproxy_balancermembers = {},
  $haproxy_userlists       = {},
  $haproxy_peers           = {},
) {

  if $manage_haproxy {

    include ::haproxy

    Haproxy::Listen {
      collect_exported => false
    }

    create_resources('haproxy::listen', $haproxy_listens)
    create_resources('haproxy::backend', $haproxy_backends)
    create_resources('haproxy::frontend', $haproxy_frontends)
    create_resources('haproxy::balancermember', $haproxy_balancermembers)
    create_resources('haproxy::userlist', $haproxy_userlists)
    create_resources('haproxy::peer', $haproxy_peers)

  }

  if $manage_firewall {
    profile::firewall::rule { '450 haproxy accept tcp':
      proto       => 'tcp',
      destination => $::ipaddress_public1,
      extras      => $firewall_extras,
    }
  }

}
