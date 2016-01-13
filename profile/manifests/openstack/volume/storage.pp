class profile::openstack::volume::storage {
  include profile::openstack::volume

  include ::cinder::volume

}
