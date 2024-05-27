class profile::openstack::image::api(
  $backend         = 'rbd',
  $manage_pruner   = true,
  $manage_cleaner  = true,
  $manage_firewall = true,
  $firewall_extras = {}
) {

  include ::glance::api
  include ::glance::config
  include ::glance::api::logging

  if $backend and $backend in ['cinder', 'file', 'rbd', 'swift', 'vsphere'] {
    include "::glance::backend::multistore::${backend}"
  } else {
    fail('Invalid glance backend selected, choose from cinder, file, rbd, swift, vsphere')
  }

  if $manage_cleaner {
    include ::glance::cache::cleaner
  }

  if $manage_pruner {
    include ::glance::cache::pruner
  }

  if $manage_firewall {
    profile::firewall::rule { '229 glance-api accept tcp':
      port   => 9292,
      extras => $firewall_extras
    }
  }
}

