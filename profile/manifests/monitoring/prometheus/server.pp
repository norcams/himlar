#
class profile::monitoring::prometheus::server(
  $manage_firewall           = false,
  $firewall_extras           = {},
  $package_name              = undef,
) {

  include ::prometheus::server

  if $package_name {
    package { 'prometheus':
      ensure => latest,
      name   => $package_name,
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '414 prometheus accept tcp':
      dport  => 9090,
      extras => $firewall_extras,
    }
  }
}
