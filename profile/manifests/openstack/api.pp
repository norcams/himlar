# Profile for the public api service
class profile::openstack::api(
  $vhosts,
  $manage_apache = false,
  $default_vhost_config = {}
) {

  if $manage_apache {
      include ::apache
  }

  include ::apache::mod::headers

  create_resources('profile::openstack::api::proxy', $vhosts)

}
