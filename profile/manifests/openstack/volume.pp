class profile::openstack::volume(
  $manage_rbd = false,
) {
  include ::cinder
  include ::cinder::ceilometer

  if $manage_rbd {
    include profile::storage::cephclient
  }
}
