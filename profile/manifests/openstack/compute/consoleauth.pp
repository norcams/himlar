#
class profile::openstack::compute::consoleauth {
  include ::nova
  include ::nova::db
}
