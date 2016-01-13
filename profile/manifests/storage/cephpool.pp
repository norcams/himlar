# Class: profile::storage::cephpool
#
#
class profile::storage::cephpool {
  require ::ceph::profile::client
  include ::ceph::profile::pool
}
