#
class profile::application::access(
  $manage_firewall = true,
  $package_url = false,
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

  if $package_url {
    package { 'himlar-dp-prep':
      provider => 'rpm',
      ensure   => 'installed',
      source   => $package_url,
      before   => Class['dpapp'],
    }
  }

}
