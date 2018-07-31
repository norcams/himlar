#
class profile::monitoring::netdata(
  $manage_firewall           = false,
  $firewall_extras           = {}
) {

  include ::netdata

  if $manage_firewall {
    profile::firewall::rule { '466 netdata accept tcp':
      dport       => 19999,
      proto       => 'tcp',
      destination => $::ipaddress_mgmt1,
      extras      => $firewall_extras,
    }
  }

}
