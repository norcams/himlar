#
class profile::openstack::compute::consoleproxy(
  $manage_firewall    = false,
  $allow_from_network = undef,
  $firewall_extras    = {},
  $spice              = false
) {
  include ::profile::openstack::compute

  if $spice =~ /true/  {
    include ::nova::spicehtml5proxy
    include ::nova::config
    $port = 6082
  } else  {
    include ::nova::vncproxy
    $port = 6080
  }


  if $manage_firewall {
    profile::firewall::rule { '222 nova-proxy accept tcp':
      port   => $port,
      extras => $firewall_extras
    }
  }

  if $spice =~ /true/  {
    package { 'openstack-nova-spicehtml5proxy':
      ensure => 'installed',
    }

    package { 'spice-html5':
      ensure => 'installed',
    }
  }

}
