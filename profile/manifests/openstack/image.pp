#
class profile::openstack::image(
  $registry_enabled = false,
  $notify_enabled   = false,
  $manage_rbd       = false,
  $manage_policy    = false,
  $manage_notify    = false
) {

  include ::profile::openstack::image::api

  if $registry_enabled {
    include ::profile::openstack::image::registry
  }

  if $notify_enabled {
    include ::profile::openstack::image::notify
  }

  if $manage_rbd {
    include profile::storage::cephclient
  }

  if $manage_policy {
    include ::glance::policy
  }

  if $manage_notify {
    include ::glance::notify::rabbitmq
  }

}
