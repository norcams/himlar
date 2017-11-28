#
class profile::application::access(
  $manage_firewall    = false,
  $package_url        = false,
  $firewall_extras    = {},
  $allow_from_network = undef,
) {

  include ::dpapp

  if $manage_firewall {
    $hiera_allow_from_network = hiera_array('allow_from_network', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }

    profile::firewall::rule { '190 dpapp-http accept tcp':
      dport       => [ 80, 443 ],
      destination => $::ipaddress_public1,
      source      => $source,
      extras      => $firewall_extras,
    }
  }

  if $package_url {
    package { 'himlar-dp-prep':
      ensure   => 'latest',
      provider => 'rpm',
      source   => $package_url,
      before   => Class['dpapp'],
      notify   => Class['apache::service']
    }
  }

}
