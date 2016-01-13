class profile::openstack::volume::backup {
  include profile::openstack::volume

  include ::cinder::backup

}
