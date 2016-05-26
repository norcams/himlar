#
class profile::application::access(
  $manage_firewall = true,
  $package_url = false,
  $firewall_extras = {},
) {

  include ::dpapp

  $allow_from_network = hiera_array('allow_from_network')

  profile::firewall::rule { '190 dpapp-http accept tcp':
    port   => [ 80, 443 ],
    destination => $::ipaddress_public1,
    source      => $allow_from_network,
    extras      => $firewall_extras,
  }

  if $package_url {
    package { 'himlar-dp-prep':
      ensure   => 'latest',
      provider => 'rpm',
      source   => $package_url,
      before   => Class['dpapp'],
    }
  }

}
