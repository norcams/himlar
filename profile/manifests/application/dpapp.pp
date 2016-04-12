#
class profile::application::dpapp(
  $manage_firewall = true
) {

  include ::dpapp

  $allow_from_network = hiera_array('allow_from_network')

  profile::firewall::rule { '190 dpapp-http accept tcp':
    port   => [ 80, 443 ],
    destination => $::ipaddress_public1,
    source      => $allow_from_network,
    extras => {
      ensure => $manage_firewall? { true => present , default => absent }
    }
  }

}
