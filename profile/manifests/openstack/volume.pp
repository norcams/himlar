class profile::openstack::volume(
  $manage_rbd    = false,
  $manage_quotas = false,
  $manage_telemetry = false
) {
  include ::cinder
  include ::cinder::client
  include ::cinder::config
  include ::cinder::ceilometer
  include ::cinder::wsgi::apache

  service { 'httpd':
    enable      => true,
    ensure      => running,
  }

  if $manage_rbd {
    include profile::storage::cephclient
  }

  if $manage_quotas {
    include cinder::quota
  }

  if $manage_telemetry {
    include ::cinder::ceilometer
  }

}
