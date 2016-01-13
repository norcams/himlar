class profile::openstack::volume::scheduler {
  include profile::openstack::volume

  include ::cinder::scheduler

}
