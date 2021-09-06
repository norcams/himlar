# Create new cephfs filesystem
define profile::storage::ceph::cephfs::fs(
  $metadata_pool     = undef,
  $primary_data_pool = undef,
) {

  exec { "cepfs_create_${name}":
    command => "ceph fs new ${name} ${metadata_pool} ${primary_data_pool}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    unless  => "ceph fs ls | gawk '{ print $2 }' | grep -w ${name}"
  }
}
