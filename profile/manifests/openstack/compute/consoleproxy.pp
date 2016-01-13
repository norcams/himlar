class profile::openstack::compute::consoleproxy(
  $manage_firewall = true,
  $firewall_extras = {}
) {
  include ::profile::openstack::compute
  include ::nova::vncproxy

  if $manage_firewall {
    profile::firewall::rule { '222 nova-novncproxy accept tcp':
      port   => 6080,
      extras => $firewall_extras
    }
  }
}
