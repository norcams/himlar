#
class profile::application::access(
  $manage_firewall    = false,
  $package_url        = false,
  $firewall_extras    = {},
  $allow_from_network = undef,
) {

  include ::dpapp

  if $manage_firewall {
    profile::firewall::rule { '190 dpapp-http accept tcp':
      dport       => [80],
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
