#
class profile::logging::kibana(
  $manage_firewall = true,
  $ports = [5601],
  $firewall_extras = {},
  $package_url = 'https://artifacts.elastic.co/downloads/kibana/kibana-6.3.2-x86_64.rpm',
  $manage_service = true,
  $manage_serverhost = true
) {

  if $package_url {
    package { 'kibana':
      ensure   => 'installed',
      provider => 'rpm',
      source   => $package_url
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '401 kibana accept tcp':
      port        => $ports,
      destination => $::ipaddress_mgmt1,
      source      => "${::network_mgmt1}/${::netmask_mgmt1}",
      extras      => $firewall_extras,
    }
  }

  if $manage_service {
    service { 'kibana':
      ensure  => running,
      require => Package['kibana']
    }
  }

  if $manage_serverhost {
    file_line { 'server_host':
      ensure => present,
      line   => 'server.host: "0.0.0.0"',
      path   => "/etc/kibana/kibana.yml",
    }
  }
}
