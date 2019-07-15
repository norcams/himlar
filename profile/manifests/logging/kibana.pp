#
class profile::logging::kibana(
  $manage_firewall = true,
  $ports = [5601],
  $firewall_extras = {},
  $package_name = 'kibana-oss',
  $service_name = 'kibana',
  $manage_service = true,
  $manage_serverhost = true
) {

  if $manage_firewall {
    profile::firewall::rule { '401 kibana accept tcp':
      port        => $ports,
      destination => $::ipaddress_mgmt1,
      source      => "${::network_mgmt1}/${::netmask_mgmt1}",
      extras      => $firewall_extras,
    }
  }


  if $manage_service {
    service { $service_name:
      ensure  => running,
      require => Package[$package_name]
    }
  }

  if $package_name {
    package { $package_name:
      ensure => installed,
    }
  }

  if $manage_serverhost {
    file_line { 'server_host':
      ensure  => present,
      line    => "server.host: \"${::ipaddress_mgmt1}\"",
      path    => '/etc/kibana/kibana.yml',
      require => Package[$package_name],
      notify  => Service[$service_name]
    }
  }

}
