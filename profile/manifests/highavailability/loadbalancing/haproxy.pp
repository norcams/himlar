#
class profile::highavailability::loadbalancing::haproxy (
  $manage_haproxy          = false,
  $anycast_enable          = false,
  $anycast_service_ip      = undef,
  $anycast_service_ip6     = undef,
  $bird_package_name       = 'bird',
  $bird_template           = "${module_name}/bird/bird-anycast-vm.conf.${::operatingsystemmajrelease}",
  $manage_firewall         = false,
  $manage_firewall6        = false,
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
  $access_list = {},
  String $merge_strategy = 'deep'
) {

  if $manage_haproxy {

    include ::haproxy

    Haproxy::Listen {
      collect_exported => false
    }

    Haproxy::Backend {
      collect_exported => false
    }

    # We with merge_strategy=deep we merge these from common, variation and location
    $haproxy_listens         = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_listens', Hash, $merge_strategy, {})
    $haproxy_frontends       = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_frontends', Hash, $merge_strategy, {})
    $haproxy_backends        = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_backends', Hash, $merge_strategy, {})
    $haproxy_balancermembers = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_balancermembers', Hash, $merge_strategy, {})
    $haproxy_userlists       = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_userlists', Hash, $merge_strategy, {})
    $haproxy_peers           = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_peers', Hash, $merge_strategy, {})
    $haproxy_mapfile         = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_mapfile', Hash, $merge_strategy, {})
    $haproxy_errorpage       = lookup('profile::highavailability::loadbalancing::haproxy::haproxy_errorpage', Hash, $merge_strategy, {})

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
      content => "watch 'echo \"show stat\" | nc -U /var/run/haproxy.sock | cut -d \",\" -f 1,2,5-11,18,24,27,30,36,50,37,56,57,62 | column -s, -t'"
    }
  }

  if $anycast_enable {
    package { $bird_package_name:
      ensure   => installed
    }
    file { '/etc/bird.conf':
      ensure   => file,
      content  => template("${bird_template}.erb"),
      notify   => Service['bird']
    }
    service { 'bird':
      ensure   => running,
      enable   => true,
      require  => Package['bird']
    }
  }

  if $manage_firewall {
    $hiera_allow_from_network = lookup('allow_from_network', Array, 'unique', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }

    validate_legacy(Hash, 'validate_hash', $firewall_extras)
    validate_legacy(Array, 'validate_array', $firewall_ports['public'])
    validate_legacy(Array, 'validate_array', $firewall_ports['internal'])
    validate_legacy(Array, 'validate_array', $firewall_ports['mgmt'])
    validate_legacy(Array, 'validate_array', $firewall_ports['limited'])

    profile::firewall::rule { '450 haproxy public accept tcp':
      proto       => 'tcp',
      destination => $::ipaddress_public1,
      dport       => $firewall_ports['public'],
      extras      => $firewall_extras,
    }
    unless empty($firewall_ports['internal']) {
      profile::firewall::rule { '451 haproxy internal accept tcp':
        proto       => 'tcp',
        destination => $::ipaddress_trp1,
        source      => "${::network_trp1}/${::netmask_trp1}",
        dport       => $firewall_ports['internal'],
        extras      => $firewall_extras,
      }
    }
    # Only monitor page on port 9000
    unless empty($firewall_ports['mgmt']) {
      profile::firewall::rule { '452 haproxy mgmt accept tcp':
        proto       => 'tcp',
        destination => $::ipaddress_mgmt1,
        source      => "${::network_mgmt1}/${::netmask_mgmt1}",
        dport       => $firewall_ports['mgmt']
      }
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

  if $manage_firewall6 {
    $hiera_allow_from_network6 = lookup('allow_from_network6', Array, 'unique', [])
    $source6 = $allow_from_network6? {
      undef   => $hiera_allow_from_network6,
      ''      => $hiera_allow_from_network6,
      default => $allow_from_network6
    }

    profile::firewall::rule { '450 haproxy public accept tcp6':
      proto       => 'tcp',
      destination => $::ipaddress6_public1,
      dport       => $firewall_ports['public'],
      extras      => $firewall_extras,
      provider    => 'ip6tables'
    }
    unless empty($firewall_ports['internal']) {
      profile::firewall::rule { '451 haproxy internal accept tcp6':
        proto       => 'tcp',
        destination => $::ipaddress6_trp1,
        source      => "${::network6_trp1}/${::cidr6_trp1}",
        dport       => $firewall_ports['internal'],
        extras      => $firewall_extras,
        provider    => 'ip6tables'
      }
    }
    unless empty($firewall_ports['limited']) {
      profile::firewall::rule { '453 haproxy limited accept tcp6':
        proto       => 'tcp',
        destination => $::ipaddress6_public1,
        source      => $source6,
        dport       => $firewall_ports['limited'],
        provider    => 'ip6tables'
      }
    }
  }

  if $manage_firewall and $anycast_enable {
    profile::firewall::rule { '011 bird allow bfd':
      proto    => 'udp',
      port     => ['3784','3785','4784','4785'],
    }
    profile::firewall::rule { "010 bird bgp - accept tcp to ${name}":
      proto    => 'tcp',
      port     => '179',
      iniface  => $::ipaddress_trp1,
    }
    profile::firewall::rule { '011 bird allow bfd ipv6':
      proto    => 'udp',
      port     => ['3784','3785','4784','4785'],
      provider => 'ip6tables',
    }
    profile::firewall::rule { "010 bird bgp ipv6 - accept tcp to ${name}":
      proto    => 'tcp',
      port     => '179',
      provider => 'ip6tables',
      iniface  => $::ipaddress6_trp1,
    }
  }

  if $anycast_enable {
    file { '/opt/haproxy-checks/':
      ensure   => directory,
    } ~>
    file { "haproxy_check.sh":
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0755',
      path     => "/opt/haproxy-checks/haproxy_health.sh",
      content  => template("${module_name}/loadbalancing/haproxy_check.erb"),
    }
    file { 'haproxy_check_service':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0644',
      path     => "/etc/systemd/system/haproxy_health.service",
      content  => template("${module_name}/loadbalancing/haproxy_check_service.erb"),
    } ~>
    service { 'haproxy_health.service':
      ensure      => running,
      enable      => true,
      hasrestart  => true,
      hasstatus   => true,
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
