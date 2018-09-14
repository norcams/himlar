# Class: profile::storage::cephpool
#
#
class profile::storage::cephpool (
  $manage_ec_pools = false,
) {
  require ::ceph::profile::client

  create_resources(ceph::pool, lookup('profile::storage::cephpool::pools', Hash, 'first', {}))
  if $manage_ec_pools {
    create_resources(profile::storage::ceph_ecpool, lookup('profile::storage::ceph_ecpool::ec_pools', Hash, 'first'))
  }
}
