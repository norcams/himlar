#
class profile::application::dpapp(
  $manage_firewall = true
) {

  include ::dpapp

  profile::firewall::rule { '190 dpapp-http accept tcp':
    port   => [ 80, 6543 ],
    destination => $::ipaddress_public1,
    extras => {
      ensure => $manage_firewall? { true => present , default => absent }
    }
  }

  profile::firewall::rule { '191 forward http to 6543 http':
    chain  => 'PREROUTING',
    port   => 80,
    destination => $::ipaddress_public1,
    extras => {
      ensure => $manage_firewall? { true => present , default => absent },
      jump => 'DNAT',
      todest => '$::ipaddress_public1:6543',
      table => 'nat',
      action => undef,
      state => undef
    }
  }

}
