# Class: profile::storage::cephfs
#
#
class profile::storage::cephfs(
  $create_cephfs = false,
  $mount_cephfs  = false,
) {

  require ::ceph::profile::client

  if $create_cephfs {
    $filesystems = lookup('profile::storage::cephfs::filesystems', Hash, 'deep', {})
    create_resources('profile::storage::ceph::cephfs::fs', $filesystems)
  }
  if $mount_cephfs {
    $mount_filesystems = lookup('profile::storage::cephfs::mount', Hash, 'deep', {})
    create_resources('profile::storage::ceph::cephfs::mount', $mount_filesystems)
  }
}
