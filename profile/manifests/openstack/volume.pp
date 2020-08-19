#
class profile::openstack::volume(
  $manage_rbd    = false,
  $manage_telemetry = false,
  $notify_service = false
) {
  include ::cinder
  include ::cinder::client
  include ::cinder::config
  include ::cinder::ceilometer
  include ::cinder::logging

  if $manage_rbd {
    include profile::storage::cephclient
  }

  if $manage_telemetry {
    include ::cinder::ceilometer
  }

  if $notify_service {
    # This will make sure httpd service will be restarted on config changes
    Cinder_config <| |> ~> Class['apache::service']
  }

}
