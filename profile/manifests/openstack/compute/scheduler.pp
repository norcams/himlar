class profile::openstack::compute::scheduler {
  include ::profile::openstack::compute
  include ::nova::scheduler
}
