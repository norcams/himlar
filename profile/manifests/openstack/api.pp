# Profile for the public api service
class profile::openstack::api(
  $vhosts,
  $default_vhost_config = {}
) {

  create_resources('profile::openstack::api::proxy', $vhosts)

}
