# Class: profile::storage::cephosd
#
#
class profile::storage::cephosd {
  include ::ceph::profile::osd

  service { 'ceph-osd':
    ensure    => running,
    name      => 'ceph',
    enable    => true,
    provider  => redhat,
    status    => "/sbin/service ceph status osd",
    start     => "/sbin/service ceph start osd",
    restart   => "/sbin/service ceph start osd",
    require   => Class[ceph::osds],
  }

  file { '/var/lib/ceph-configured':
    ensure    => file,
    require   => Class[ceph::osds],
    notify    => Exec['initial start of osds'],
  }

  # ceph service must be started once before service status works
  exec { 'initial start of osds':
    command     => '/sbin/service ceph start osd',
    require     => File['/var/lib/ceph-configured'],
    refreshonly => true,
  }
}
