class profile::openstack::volume {
  include ::cinder
  include ::cinder::ceilometer
}
