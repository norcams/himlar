#
class profile::logging::kibana(
  $manage_firewall = true,
  $ports = [5601],
  $firewall_extras = {},
  $package_url = 'https://download.elastic.co/kibana/kibana/kibana-4.5.0-1.x86_64.rpm',
  $manage_service = true
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
      ensure => running
    }
  }

}
