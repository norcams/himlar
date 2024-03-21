#
class profile::openstack::volume(
  $manage_rbd    = false,
  $notify_service = false,
  $manage_osprofiler = false
) {
  include ::cinder
  include ::cinder::nova
  include ::cinder::client
  include ::cinder::config
  include ::cinder::logging

  if $manage_rbd {
    include profile::storage::cephclient
  }

  if $notify_service {
    # This will make sure httpd service will be restarted on config changes
    Cinder_config <| |> ~> Class['apache::service']
  }

  if $manage_osprofiler {
    include ::cinder::deps
    $osprofiler_config = lookup('profile::logging::osprofiler::osprofiler_config', Hash, 'first', {})
    create_resources('cinder_config', $osprofiler_config)
  }

}
