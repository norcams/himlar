#
class profile::openstack::compute::scheduler {
  include ::nova
  include ::nova::scheduler
  include ::nova::scheduler::filter
}
