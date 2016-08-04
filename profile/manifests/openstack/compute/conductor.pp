#
class profile::openstack::compute::conductor {
  include ::nova
  include ::nova::conductor
}
