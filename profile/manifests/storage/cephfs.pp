# Class: profile::storage::cephfs
#
#
class profile::storage::cephfs(
  $create_cephfs = false,
  $mount_cephfs  = false,
  $set_fsparams  = false, # If configuring data pools mount_cephfs is required
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
  if $set_fsparams and $mount_cephfs {
    $fs_params = lookup('profile::storage::cephfs::fs_params', Hash, 'deep', {})
    create_resources('profile::storage::ceph::cephfs::fs_params', $fs_params)
  }
}
