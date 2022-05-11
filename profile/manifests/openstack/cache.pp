#
class profile::openstack::cache {
  include ::keystone::cache
  include ::memcached
}
