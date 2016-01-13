class profile::openstack::compute::cert {
  include ::profile::openstack::compute
  include ::nova::cert
}
