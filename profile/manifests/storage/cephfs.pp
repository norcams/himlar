# Class: profile::storage::cephfs
#
#
class profile::storage::cephfs(
  $create_cephfs = false,
) {

  require ::ceph::profile::client

  if $create_cephfs {
    $filesystems = lookup('profile::storage::cephfs::filesystems', Hash, 'deep', {})
    create_resources('ceph::fs', $filesystems)
  }
}
