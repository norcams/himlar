#
define profile::storage::loopback(
  $base_dir     = '/mnt',
  $byte_size    = '1024',
  $seek         = '25000',
  $ext_args     = '',
) {

  if(!defined(File[$base_dir])) {
    file { $base_dir:
      ensure => directory,
      before => Exec["create_partition-${name}"]
    }
  }

  exec { "create_partition-${name}":
    command => "dd if=/dev/zero of=${base_dir}/${name} bs=${byte_size} count=0 seek=${seek}",
    path    => ['/usr/bin/', '/bin'],
    unless  => "test -f ${base_dir}/${name}",
  } ->
  exec { "create_loopback_device-${name}":
    command => "losetup \$(losetup -f) ${base_dir}/${name}",
    path    => ['/usr/bin/', '/sbin'],
    unless  => "losetup -l | grep ${name}",
    notify  => Exec["initialize_physical_volue-${name}"]
  }

  exec { "initialize_physical_volue-${name}":
    command     => 'pvcreate -ff -y /dev/loop1',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
  }

}
