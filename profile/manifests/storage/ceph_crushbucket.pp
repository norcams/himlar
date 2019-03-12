#
# Add crush buckets and move them to the right place
#
define profile::storage::ceph_crushbucket (
  $bucket_type         = "pod",
  $bucket_parent       = "default",
) {

  exec { "create_ceph_crushbucket-${name}":
    command     => "/bin/ceph osd crush add-bucket ${name} ${bucket_type} && /bin/ceph osd crush move ${name} root=${bucket_parent}",
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    unless      => "/bin/ceph osd crush tree | grep ${bucket_type} | grep ${name}",
  }
}
