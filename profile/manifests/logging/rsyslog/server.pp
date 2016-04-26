# rsyslog server
class profile::logging::rsyslog::server(
  $manage_firewall = true,
  $firewall_extras = {},
) {

  include ::rsyslog::server


  profile::firewall::rule { '150 rsyslog accept udp':
    port        => [ 514 ],
    destination => $::ipaddress_mgmt1,
    proto       => 'udp',
    extras      => $firewall_extras,
  }

  profile::firewall::rule { '150 rsyslog accept tcp':
    port        => [ 514 ],
    destination => $::ipaddress_mgmt1,
    proto       => 'tcp',
    extras      => $firewall_extras,
  }

}
