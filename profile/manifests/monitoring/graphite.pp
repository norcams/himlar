#
class profile::monitoring::graphite (
  $manage_graphite = false,
  $manage_monitor_logrotate = false,
  $carbon_log_path = '/opt/graphite/storage/log/carbon-cache/carbon-cache-a/',
  $age = '12w',
  $recurse = true,
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
  }

  if $carbon_log_path {
    tidy { 'carbon-cache':
      path => $carbon_log_path,
      age => $age,
      recurse => $recurse,
    }
  }
}
