#
class profile::openstack::image(
  $registry_enabled = false,
  $notify_enabled   = false,
) {

  include ::profile::openstack::image::api

  if $registry_enabled {
    include ::profile::openstack::image::registry
  }

  if $notify_enabled {
    include ::profile::openstack::image::notify
  }

}
