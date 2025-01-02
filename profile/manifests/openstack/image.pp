#
class profile::openstack::image(
  $notify_enabled   = false,
  $manage_policy    = false,
  $manage_notify    = false,
  $manage_osprofiler = false,
) {

  include ::profile::openstack::image::api

  if $notify_enabled {
    include ::profile::openstack::image::notify
  }

  if $manage_policy {
    include ::glance::policy
  }

  if $manage_notify {
    include ::glance::notify::rabbitmq
  }

  if $manage_osprofiler {
    include ::glance::deps
    $osprofiler_config = lookup('profile::logging::osprofiler::osprofiler_config', Hash, 'first', {})
    create_resources('glance_api_config', $osprofiler_config)
  }
}
