class profile::openstack::volume(
  $manage_rbd    = false,
  $manage_quotas = false
) {
  include ::cinder
  include ::cinder::client
  include ::cinder::ceilometer

  if $manage_rbd {
    include profile::storage::cephclient
  }

  if $manage_quotas {
    include cinder::quota
  }
}
