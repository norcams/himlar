# Class: profile::storage::cephpool
#
#
class profile::storage::cephpool {
  require ::ceph::profile::client

  create_resources(ceph::pool, lookup('profile::storage::cephpool::pools', Hash, 'first', {}))
}
