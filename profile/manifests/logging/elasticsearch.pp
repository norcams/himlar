#
class profile::logging::elasticsearch(
  $instances = {},
  $manage_firewall = true,
  $ports = [9200]
) {

  include ::elasticsearch

  create_resources('elasticsearch::instance', $instances)

  if $manage_firewall {
    $allow_from_network = hiera_array('allow_from_network')
    profile::firewall::rule { '400 elasticsearch accept tcp':
      port    => $ports,
      source  => $ipaddress_mgmt1,
      extras  => $firewall_extras,
    }
  }

}
