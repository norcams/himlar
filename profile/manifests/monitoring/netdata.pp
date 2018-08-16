#
class profile::monitoring::netdata(
  $manage_firewall           = false,
  $firewall_dest             = $::ipaddress_mgmt1,
  $firewall_extras           = {}
) {

  include ::netdata

  if $manage_firewall {
    profile::firewall::rule { '466 netdata accept tcp':
      dport       => 19999,
      proto       => 'tcp',
      destination => $firewall_dest,
      extras      => $firewall_extras,
    }
  }

}
