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
  # Configure SELinux to enforcing
  class { 'selinux':
    mode => 'enforcing',
    type => 'targeted',
  }
  # Set boolean named_write_master_zones, so that named is allowed to write
  # master zones
  selinux::boolean { 'named_write_master_zones':
    ensure     => 'on',
    persistent => true,
  }
  # Install packages that we want when running SELinux
  package { 'setroubleshoot-server':
    ensure => installed,
  }
  package { 'setools-console':
    ensure => installed,
  }

  # Our reverse zones
  $reverse_zones = hiera_hash('profile::dns::ns::ptr_zones', {})

  # Make sure that bind is installed
  package { 'bind':
    ensure => installed,
  }
  # Create rndc.conf
  file { '/etc/rndc.conf':
    content      => template("${module_name}/dns/bind/rndc.conf.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'named',
    group        => 'named',
    require      => Package['bind'],
  }
  # Ensure that /var/named exists with correct permissions
  file { '/var/named':
    ensure       => directory,
    mode         => '0770',
    owner        => 'root',
    group        => 'named',
    require      => Package['bind'],
  }
  # Create zone file for the internal zone (on master)
  if $master {
    file { "/var/named/${internal_zone}.zone":
      content      => template("${module_name}/dns/bind/${internal_zone}.zone.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
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
  if $master {
    service { 'named':
      ensure  => running,
      enable  => true,
      require => [
                   File['/etc/rndc.conf'],
                   File['/var/named'],
                   File["/var/named/${internal_zone}.zone"],
                   File['/etc/named.conf']
                 ],
    }
  }
  else {
    service { 'named':
      ensure  => running,
      enable  => true,
      require => [
                   File['/etc/rndc.conf'],
                   File['/var/named'],
                   File['/etc/named.conf']
                 ],
    }
  }

  # Create the reverse zones (on master)
  if $master {
    create_resources('profile::dns::reverse_zone', $reverse_zones)
  }

  # Open nameserver ports in the firewall
  if $manage_firewall {
    profile::firewall::rule { '001 dns incoming tcp':
      port   => 53,
      proto  => 'tcp'
    }
    profile::firewall::rule { '002 dns incoming udp':
      port   => 53,
      proto  => 'udp'
    }
    profile::firewall::rule { '003 rndc incoming - bind only':
      port   => 953,
      proto  => 'tcp',
      extras => $firewall_extras
    }
  }
}
