class profile::openstack::compute::consoleauth {
  include ::profile::openstack::compute
  include ::nova::consoleauth
}
