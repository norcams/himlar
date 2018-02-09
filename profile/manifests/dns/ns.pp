class profile::dns::ns (
  $my_mgmt_addr = {},
  $my_transport_addr = {},
  #$mdns_transport_addr = {},
  $admin_mgmt_addr = {},
  $ns1_mgmt_addr = {},
  $ns2_mgmt_addr = {},
  $ns1_transport_addr = {},
  $ns1_public_addr = {},
  $master = {},
  $manage_firewall = {},
  $firewall_extras = {},
  $internal_zone = {}
  )
{
  # Our forward zones
  $forward_zones = lookup('profile::dns::ns::fw_zones', Hash, 'deep', {})

  # Our reverse zones
  $reverse_zones = lookup('profile::dns::ns::ptr_zones', Hash, 'deep', {})

  # Make sure that bind is installed
  package { 'bind':
    ensure => installed,
  }
  # Create rndc.conf
  file { '/etc/rndc.conf':
    content => template("${module_name}/dns/bind/rndc.conf.erb"),
    notify  => Service['named'],
    mode    => '0640',
    owner   => 'named',
    group   => 'named',
    require => Package['bind'],
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

  # Create the zones (on master)
  if $master {
    create_resources('profile::dns::forward_zone', $forward_zones)
    create_resources('profile::dns::reverse_zone', $reverse_zones)
  }

  # Open nameserver ports in the firewall
  if $manage_firewall {
    profile::firewall::rule { '001 dns incoming tcp':
      dport => 53,
      proto => 'tcp'
    }
    profile::firewall::rule { '002 dns incoming udp':
      dport => 53,
      proto => 'udp'
    }
    profile::firewall::rule { '003 rndc incoming - bind only':
      dport  => 953,
      proto  => 'tcp',
      extras => $firewall_extras
    }
  }
}
