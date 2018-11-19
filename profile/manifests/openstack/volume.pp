class profile::openstack::volume(
  $manage_rbd    = false,
  $manage_telemetry = false
) {
  include ::cinder
  include ::cinder::client
  include ::cinder::config
  include ::cinder::ceilometer

  if $manage_rbd {
    include profile::storage::cephclient
  }

  if $manage_telemetry {
    include ::cinder::ceilometer
  }

}
