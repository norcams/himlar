class profile::openstack::volume(
  $enable_rbd = false,
) {
  include ::cinder
  include ::cinder::ceilometer

  if $enable_rbd {
    include profile::storage::cephclient
  }
}
