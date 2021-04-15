#
# This will setup the sensu backend services
#
class profile::monitoring::sensu::backend(
  Boolean $manage             = false,
  Boolean $manage_dashboard   = false,
  Boolean $manage_firewall    = false,
  Array $firewall_ports       = [8081, 3000, 8082],
  String $merge_strategy      = 'deep',
) {

  if $manage {
    include ::sensu::backend
    include ::sensu::cli
    include ::sensu::agent

    $namespaces = lookup('profile::monitoring::sensu::backend::namespaces', Hash, 'deep', {})
    create_resources('sensu_namespace', $namespaces)
  }

  if $manage_firewall {
    profile::firewall::rule { '411 sensu accept tcp':
      dport       => $firewall_ports,
      destination => $::ipaddress_mgmt1,
#      extras      => $firewall_extras,
    }
  }
}
