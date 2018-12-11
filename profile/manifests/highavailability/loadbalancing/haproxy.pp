#
class profile::highavailability::loadbalancing::haproxy (
  $manage_haproxy          = false,
  $manage_firewall         = false,
  $allow_from_network      = undef,
  $firewall_extras         = {},
  $firewall_ports          = {
    'public'   => ['5000'],
    'internal' => ['35357'],
    'limited'  => ['80','443'],
    'mgmt'     => ['9000']
  },
  $enable_nonlocal_bind    = false,
  $enable_remote_logging   = false,
  $access_list = {}
) {

  if $manage_haproxy {

    include ::haproxy

    Haproxy::Listen {
      collect_exported => false
    }

    Haproxy::Backend {
      collect_exported => false
    }

    # We need to merge these from common and location
    $haproxy_listens         = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_listens', Hash, 'deep', {})
    $haproxy_frontends       = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_frontends', Hash, 'deep', {})
    $haproxy_backends        = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_backends', Hash, 'deep', {})
    $haproxy_balancermembers = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_balancermembers', Hash, 'deep', {})
    $haproxy_userlists       = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_userlists', Hash, 'deep', {})
    $haproxy_peers           = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_peers', Hash, 'deep', {})
    $haproxy_mapfile         = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_mapfile', Hash, 'deep', {})
    $haproxy_errorpage       = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_errorpage', Hash, 'deep', {})

    create_resources('haproxy::listen', $haproxy_listens)
    create_resources('haproxy::backend', $haproxy_backends)
    create_resources('haproxy::frontend', $haproxy_frontends)
    create_resources('haproxy::balancermember', $haproxy_balancermembers)
    create_resources('haproxy::userlist', $haproxy_userlists)
    create_resources('haproxy::mapfile', $haproxy_mapfile)
    create_resources('haproxy::peer', $haproxy_peers)
    create_resources('profile::highavailability::loadbalancing::haproxy::list', $access_list)
    create_resources('profile::highavailability::loadbalancing::haproxy::errorpage', $haproxy_errorpage)

    file { '/root/watch-status.sh':
      ensure  => present,
      mode    => '0755',
      content => "watch 'echo \"show stat\" | nc -U /var/lib/haproxy/stats | cut -d \",\" -f 1,2,5-11,18,24,27,30,36,50,37,56,57,62 | column -s, -t'"
    }

  }

  if $manage_firewall {
    $hiera_allow_from_network = lookup('allow_from_network', Array, 'unique', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }

    validate_hash($firewall_extras)
    validate_array($firewall_ports['public'])
    validate_array($firewall_ports['internal'])
    validate_array($firewall_ports['mgmt'])
    validate_array($firewall_ports['limited'])

    profile::firewall::rule { '450 haproxy public accept tcp':
      proto       => 'tcp',
      destination => $::ipaddress_public1,
      dport       => $firewall_ports['public'],
      extras      => $firewall_extras,
    }
    profile::firewall::rule { '451 haproxy internal accept tcp':
      proto       => 'tcp',
      destination => $::ipaddress_trp1,
      source      => "${::network_trp1}/${::netmask_trp1}",
      dport       => $firewall_ports['internal'],
      extras      => $firewall_extras,
    }
    # Only monitor page on port 9000
    profile::firewall::rule { '452 haproxy mgmt accept tcp':
      proto       => 'tcp',
      destination => $::ipaddress_mgmt1,
      source      => "${::network_mgmt1}/${::netmask_mgmt1}",
      dport       => $firewall_ports['mgmt']
    }
    # Limited access for 80 and 443
    unless empty($firewall_ports['limited']) {
      profile::firewall::rule { '453 haproxy limited accept tcp':
        proto       => 'tcp',
        destination => $::ipaddress_public1,
        source      => $source,
        dport       => $firewall_ports['limited']
      }
    }
  }

  if $enable_nonlocal_bind {
    sysctl::value { 'net.ipv4.ip_nonlocal_bind':
      value => 1,
    }
  }

  # This will not work with rsyslog module!!
  if $enable_remote_logging {
    file_line { 'enable udp module in rsyslog':
      path   => '/etc/rsyslog.conf',
      line   => '$ModLoad imudp',
      match  => 'ModLoad\ imudp',
      notify => Service['rsyslog']
    }
    file_line { 'udp port in rsyslog':
      path   => '/etc/rsyslog.conf',
      line   => '$UDPServerRun 514',
      match  => 'UDPServerRun\ 514',
      notify => Service['rsyslog']
    }
    file_line { 'rsyslog facility for haproxy':
      path   => '/etc/rsyslog.conf',
      line   => 'local6.* -/var/log/haproxy.log',
      match  => '^local6',
      notify => Service['rsyslog']
    }
    service { 'rsyslog':
      ensure => 'running'
    }
  }

}
