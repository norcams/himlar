# Class: profile::storage::cephpool
#
#
class profile::storage::cephpool {
  require ::ceph::profile::client

  create_resources(ceph::pool, hiera('profile::storage::cephpool::pools', {}))
}
