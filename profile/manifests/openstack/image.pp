class profile::openstack::image(
  $registry_enabled = true,
) {

  include ::profile::openstack::image::api

  if $registry_enabled {
    include ::profile::openstack::image::registry
  }

}
