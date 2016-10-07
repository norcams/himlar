#
class profile::monitoring::grafana(
  $manage_firewall           = false,
  $firewall_extras           = {}
) {

  include ::grafana

  if $manage_firewall {
    profile::firewall::rule { '412 grafana accept tcp':
      port        => 8080,
      destination => $::ipaddress_mgmt1,
      extras      => $firewall_extras,
    }
  }
}
