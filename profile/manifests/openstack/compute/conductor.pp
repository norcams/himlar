class profile::openstack::compute::conductor {
  include ::profile::openstack::compute
  include ::nova::conductor
}
