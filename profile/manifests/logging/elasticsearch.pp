#
class profile::logging::elasticsearch(
  $instances = {},
  $manage_firewall = true,
  $ports = [9200],
  $firewall_extras = {},
) {

  include ::elasticsearch

  create_resources('elasticsearch::instance', $instances)

  if $manage_firewall {
    $allow_from_network = hiera_array('allow_from_network')
    profile::firewall::rule { '400 elasticsearch accept tcp':
      port        => $ports,
      destination => $::ipaddress_mgmt1,
      source      => "${::network_mgmt1}/${::netmask_mgmt1}",
      extras      => $firewall_extras,
    }
  }

}
