#
class profile::openstack::compute::consoleauth {
  include ::nova
  include ::nova::db
  include ::nova::keystone::service_user
}
