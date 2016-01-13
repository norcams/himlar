class profile::openstack::image::registry (
  $manage_firewall = true,
  $firewall_extras = {}
) {
  include ::glance::registry

  if $manage_firewall {
    profile::firewall::rule { '227 glance-registry accept tcp':
      port   => 9191,
      extras => $firewall_extras
    }
  }
}
