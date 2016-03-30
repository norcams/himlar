#
define profile::openstack::api::proxy(
  $port,
  $proxy_dest,
  $extra = {},
  $defaults = $profile::openstack::api::default_vhost_config,
) {

  $basic = {
    servername => $servername,
    port => $port,
    proxy_dest => $proxy_dest
  }

  $config = merge($defaults, merge($basic, $extra))

  create_resources('::apache::vhost', { "${title}" => $config })

}
