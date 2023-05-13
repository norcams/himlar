class profile::dns::ns (
  $allowed_nets = undef,
  $allowed_transfer_nets = undef,
  $check_named_health = false,
  $enable_bird = false,
  $bird_template = "${module_name}/bird/bird-resolver.conf.${::operatingsystemmajrelease}",
  $enable_bird6 = false,
  $my_mgmt_addr = $::ipaddress_mgmt1,
  $my_transport_addr = $::ipaddress_trp1,
  $use_public_ip = false,
  $mdns_transport_addr = {},
  $mdns_public_addr = {},
  $admin_mgmt_addr = {},
  $login_mgmt_addr = {},
  $ns_mgmt_addr = {},
  $ns_transport_addr = {},
  $ns_public_addr = {},
  $ns_public6_addr = {},
  $authoritative = {},
  $manage_firewall = {},
  $manage_bird_firewall = false,
  $manage_bird6_firewall = false,
  $firewall_extras = {},
  $public_zone = {},
  $forward_everything = false,
  $forwarders = {},
  $ns_master_ip_addresses = {},
  $ns_slave_ip_addresses = {},
  $hostmaster = {},
  $ns_master = {},
  $enable_rpz = false,
  )
{

  # Find my public IP, if use_public_ip = true. We'll try IPv6 first,
  # fallback to IPv4
  if $use_public_ip {
    if fact('ipaddress6_public1') {
      $my_public_addr = $::ipaddress6_public1
    }
    else {
      $my_public_addr = $::ipaddress_public1
    }
  }

  # Our forward zones
  $forward_zones = lookup('profile::dns::ns::fw_zones', Hash, 'deep', {})

  # Our reverse zones
  $reverse_zones = lookup('profile::dns::ns::ptr_zones', Hash, 'deep', {})

  # Our slave zones
  $fw_slave_zones = lookup('profile::dns::ns::fw_slave_zones', Hash, 'deep', {})
  $ptr_slave_zones = lookup('profile::dns::ns::ptr_slave_zones', Hash, 'deep', {})

  # Make sure that bind is installed
  package { 'bind':
    ensure => installed,
  }
  if $authoritative {
    # Create rndc.conf
    file { '/etc/rndc.conf':
      content => template("${module_name}/dns/bind/rndc.conf.erb"),
      notify  => Service['named'],
      mode    => '0640',
      owner   => 'named',
      group   => 'named',
      require => Package['bind'],
    }
  }
  # Ensure that /var/named exists with correct permissions
  file { '/var/named':
    ensure  => directory,
    mode    => '0770',
    owner   => 'root',
    group   => 'named',
    require => Package['bind'],
  }
  # Ensure that /var/named/pz exists with correct permissions
  file { '/var/named/pz':
    ensure  => directory,
    mode    => '0770',
    owner   => 'root',
    group   => 'named',
    require => Package['bind'],
  }
  # Ensure that /var/named/sz exists with correct permissions
  file { '/var/named/sz':
    ensure  => directory,
    mode    => '0770',
    owner   => 'root',
    group   => 'named',
    require => Package['bind'],
  }
  # Create named.conf from template
  file { '/etc/named.conf':
    content      => template("${module_name}/dns/bind/named.conf.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'root',
    group        => 'named',
    validate_cmd => '/usr/sbin/named-checkconf %',
    require      => Package['bind'],
  }

  # Define dependencies for the named service
  if $authoritative {
    service { 'named':
      ensure  => running,
      enable  => true,
      require => [
        File['/etc/rndc.conf'],
        File['/var/named'],
        File['/var/named/pz'],
        File['/var/named/sz'],
        File['/etc/named.conf']
        ],
    }
  }
  else {
    service { 'named':
      ensure  => running,
      enable  => true,
      require => [
        File['/var/named'],
        File['/var/named/pz'],
        File['/var/named/sz'],
        File['/etc/named.conf']
        ],
    }
  }

  # Create the zones (on authoritative host)
  if $authoritative {
    create_resources('profile::dns::forward_zone', $forward_zones)
    create_resources('profile::dns::reverse_zone', $reverse_zones)
  }

  # Open nameserver ports in the firewall
  if $manage_firewall {
    $rndc_sources_ipv4 = lookup('profile::dns::ns::rndc_sources_ipv4', Array, 'unique', ['127.0.0.1/8'])
    $rndc_sources_ipv6 = lookup('profile::dns::ns::rndc_sources_ipv6', Array, 'unique', ['::1/128'])
    profile::firewall::rule { '001 dns incoming tcp':
      dport => 53,
      proto => 'tcp'
    }
    profile::firewall::rule { '001 dns incoming tcp IPv6':
      dport    => 53,
      proto    => 'tcp',
      provider => 'ip6tables'
    }
    profile::firewall::rule { '002 dns incoming udp':
      dport => 53,
      proto => 'udp'
    }
    profile::firewall::rule { '002 dns incoming udp IPv6':
      dport    => 53,
      proto    => 'udp',
      provider => 'ip6tables'
    }
    profile::firewall::rule { '003 rndc incoming':
      dport  => 953,
      proto  => 'tcp',
      source => $rndc_sources_ipv4
    }
    profile::firewall::rule { '003 rndc incoming IPv6':
      dport    => 953,
      proto    => 'tcp',
      source   => $rndc_sources_ipv6,
      provider => 'ip6tables'
    }
  }

  # Use BGP for anycast
  if $enable_bird {
    package { 'bird':
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
  if $manage_bird_firewall {
    profile::firewall::rule { '011 bird allow bfd':
      proto    => 'udp',
      port     => ['3784','3785','4784','4785'],
    }
    profile::firewall::rule { "010 bird bgp - accept tcp to ${name}":
      proto    => 'tcp',
      port     => '179',
      iniface  => $::ipaddress_trp1,
    }
  }
  if $enable_bird6 {
    package { 'bird6':
      ensure   => installed
    }
    file { '/etc/bird6.conf':
      ensure   => file,
      content  => template("${module_name}/bird/bird-resolver.conf6.erb"),
      notify   => Service['bird6']
    }
    service { 'bird6':
      ensure   => running,
      enable   => true,
      require  => Package['bird6']
    }
  }
  if $manage_bird6_firewall {
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
  if $check_named_health {
    file { '/opt/named-checks/':
      ensure   => directory,
    } ~>
    file { "named_check.sh":
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0755',
      path     => "/opt/named-checks/named_health.sh",
      content  => template("${module_name}/dns/bind/named_check.erb"),
    }
    file { 'named_check_service':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0644',
      path     => "/etc/systemd/system/named_health.service",
      content  => template("${module_name}/dns/bind/named_check_service.erb"),
    } ~>
    service { 'named_health.service':
      ensure      => running,
      enable      => true,
      hasrestart  => true,
      hasstatus   => true,
    }
  }
}
