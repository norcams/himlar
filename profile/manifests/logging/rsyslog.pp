# rsyslog server
class profile::logging::rsyslog(
  $manage_firewall = true
) {

  include ::rsyslog::server

  profile::firewall::rule { '150 rsyslog accept udp':
    port   => [ 514 ],
    destination => $::ipaddress_mgmt1,
#    source      => $::netmask_mgmt1,
    proto       => 'udp',
    extras => {
      ensure => $manage_firewall? { true => present , default => absent }
    }
  }

}
