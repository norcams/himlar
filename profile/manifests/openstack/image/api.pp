class profile::openstack::image::api(
  $manage_pruner               = true,
  $manage_cleaner              = true,
  $manage_firewall             = true,
  $create_glance_stores        = false,
  $stores_cinder               = undef,
  $stores_rbd                  = undef,
  $stores_swift                = undef,
  $glance_store_merge_strategy = 'first',
  $firewall_extras = {}
) {

  include ::glance::api
  include ::glance::config
  include ::glance::api::logging
  include ::glance::wsgi::apache

  if $create_glance_stores and ( $stores_cinder or $stores_rbd or $stores_swift ) {
    if $stores_cinder {
      create_resources(glance::backend::multistore::cinder, lookup('profile::openstack::image::api::stores_cinder', Hash, $glance_store_merge_strategy, {}))
    }
    if $stores_rbd {
      create_resources(glance::backend::multistore::rbd, lookup('profile::openstack::image::api::stores_rbd', Hash, $glance_store_merge_strategy, {}))
    }
    if $stores_swift {
      create_resources(glance::backend::multistore::swift, lookup('profile::openstack::image::api::stores_swift', Hash, $glance_store_merge_strategy, {}))
    }
  } elsif $create_glance_stores {
    create_resources(glance::backend::multistore::file, { files => { store_description => "default file store" }})
  }

  if $manage_cleaner {
    include ::glance::cache::cleaner
  }

  if $manage_pruner {
    include ::glance::cache::pruner
  }

  if $manage_firewall {
    profile::firewall::rule { '229 glance-api accept tcp':
      dport  => 9292,
      extras => $firewall_extras
    }
  }
}

