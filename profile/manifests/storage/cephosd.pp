# Class: profile::storage::cephosd
#
#
class profile::storage::cephosd {
  include ::ceph::profile::osd

  service { 'ceph-osd':
    name      => 'ceph',
    ensure    => running,
    enable    => true,
    provider  => 'init',
    status    => "/sbin/service ceph status osd",
    start     => "/sbin/service ceph start osd",
    restart   => "/sbin/service ceph start osd",
  }
}
