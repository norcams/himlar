# Mount cephfs filesystem
define profile::storage::ceph::cephfs::mount(
  $ensure               = present,          # set to mounted to actually mount the file system
  $fstype               = 'ceph',
  $local_mountdir_owner = 'root',
  $device               = ':/',             # Exmaples: :/ecdata or :/ to mount a subdir in cephfs or the cephfs root
  $user                 = 'admin',          # Client keys must exist in /etc/ceph
  $mount_options        = '_netdev,noauto', # String of generic mount options as they appear in fstab, should always contain _netdev
) {

  exec { "create_mountdir_${name}":
    command => "mkdir -p ${name}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    unless  => "test -d ${name}",
  } ~>
  file { "local_mountdir_${name}":
    ensure  => directory,
    path    => $name,
    owner   => $local_mountdir_owner,
    recurse => true,
  }

  $mount_opts = "name=${user},${mount_options}"

  mount { $name:
    ensure  => $ensure,
    fstype  => $fstype,
    device  => $device,
    options => $mount_opts,
  }
}
