# This is used to make ceph_osds fact work on storage nodes with ceph
class profile::monitoring::collectd::ceph(
  $enable  = false,
) {

  class { 'collectd::plugin::ceph':
    daemons => $::ceph_osds
  }

}
