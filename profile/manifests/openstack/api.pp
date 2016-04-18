# Profile for the public api service
class profile::openstack::api(
  $vhosts,
  $default_vhost_config = {}
) {

  include ::apache::mod::headers

  create_resources('profile::openstack::api::proxy', $vhosts)

}
