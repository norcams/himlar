# rsyslog server
class profile::logging::rsyslog::server(
  $manage_firewall = true
) {

  include ::rsyslog::server

  profile::firewall::rule { '150 rsyslog accept udp':
    port   => [ 514 ],
    destination => $::ipaddress_mgmt1,
    proto       => 'udp',
    extras => {
      ensure => $manage_firewall? { true => present , default => absent }
    }
  }

  profile::firewall::rule { '150 rsyslog accept tcp':
    port   => [ 514 ],
    destination => $::ipaddress_mgmt1,
    proto       => 'tcp',
    extras => {
      ensure => $manage_firewall? { true => present , default => absent }
    }
  }

}
