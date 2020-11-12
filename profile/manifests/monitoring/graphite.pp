#
class profile::monitoring::graphite (
  $manage_graphite          = false,
  $manage_monitor_logrotate = false,
  $path     = '',
  $age      = '12w',
  $recurse  = true,
  $matches  = '.*log.*',
) {

  if $manage_graphite {
    include ::graphite

    # Used by collectd
    profile::firewall::rule { '415 graphite accept udp':
      dport       => [2003],
      destination => $::ipaddress_mgmt1,
      proto       => 'udp',
      source      => "${::network_mgmt1}/${::netmask_mgmt1}"
    }
  }

  if $manage_monitor_logrotate {
    tidy { 'carbon-cache':
      path      => $path,
      age       => $age,
      recurse   => $recurse,
      matches   => $matches,
    }
  }
}
