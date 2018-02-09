#
class profile::openstack::compute::consoleproxy(
  $manage_firewall    = false,
  $allow_from_network = undef,
  $firewall_extras    = {},
  $spice              = false
) {
  include ::profile::openstack::compute

  if $spice {
    include ::nova::spicehtml5proxy
    include ::nova::config
    $port = 6082
  } else  {
    include ::nova::vncproxy
    $port = 6080
  }


  if $manage_firewall {
    $hiera_allow_from_network = lookup('allow_from_network', Array, 'deep', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }

    profile::firewall::rule { '222 nova-proxy accept tcp':
      port   => $port,
      extras => $firewall_extras
    }
  }

  if $spice {
    package { 'openstack-nova-spicehtml5proxy':
      ensure => 'installed',
    }

    package { 'spice-html5':
      ensure => 'installed',
    }
  }

}
