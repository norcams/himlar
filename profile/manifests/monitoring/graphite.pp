#
class profile::monitoring::graphite (
  $manage_graphite = false,
  $manage_monitor_logrotate = false,
  $carbon_log_path = '/opt/graphite/storage/log/carbon-cache/carbon-cache-a/',
  $age = '12w',
  $recurse = true,
  $manage_firewall = false,
) {

  if $manage_graphite {
    include ::graphite

    # Used by collectd
    profile::firewall::rule { '415 graphite accept udp':
      dport => [2003],
      destination => $::ipaddress_mgmt1,
      proto => 'udp',
      source => "${::network_mgmt1}/${::netmask_mgmt1}"
    }
    # Older collectd versions need tcp
    profile::firewall::rule { '416 graphite accept tcp':
      dport => [2003],
      destination => $::ipaddress_mgmt1,
      proto => 'tcp',
      source => "${::network_mgmt1}/${::netmask_mgmt1}"
    }

    if $manage_firewall {
      profile::firewall::rule { '414 graphite accept web tcp':
        dport       => [80],
        destination => $::ipaddress_mgmt1,
        proto       => 'tcp',
        source      => "${::network_mgmt1}/${::netmask_mgmt1}"
      }
    }
  }

  if $carbon_log_path {
    tidy { 'carbon-cache':
      path => $carbon_log_path,
      age => $age,
      recurse => $recurse,
    }
  }
}
