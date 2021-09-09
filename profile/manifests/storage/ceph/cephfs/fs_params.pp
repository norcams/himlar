# Set parameters of cephfs filesystem
define profile::storage::ceph::cephfs::fs_params(
  $local_mountpath     = undef,
  $datapools           = {},
  $poolmappings        = [],
  $settings            = [], # Generic settings available for ceph fs set command
) {

  if ! $settings.empty {
    $settings.each |String $setting, String $settingvalue| {
      exec { "${name}_set_${setting}":
        command => "ceph fs set ${name} ${setting} ${settingvalue}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        unless  => "ceph fs get ${name} | grep ${setting} | grep -w ${settingvalue}",
      }
    }
  }

  if ! $datapools.empty {
    $datapools.each |String $poolname, Hash $params| {
      exec { "add_${poolname}_to_${name}":
        command => "ceph fs add_data_pool ${name} ${poolname}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        unless  => "ceph fs ls | grep -w ${poolname}"
      }
    }
    $poolmappings.each |String $cephfs_dir, String $mapping| {
      file { "${name}_${cephfs_dir}":
        ensure => directory,
        path   => "${local_mountpath}/${cephfs_dir}",
      }
      exec { "${name}_create_mapping_${cephfs_dir}":
        command => "setfattr -n ceph.dir.layout.pool -v ${mapping} ${local_mountpath}/${cephfs_dir}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        unless  => "getfattr -n ceph.dir.layout.pool ${local_mountpath}/${cephfs_dir} | grep -w ${mapping}",
      }
    }
  }
}
