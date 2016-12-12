# Class: profile::storage::cephosd
#
#
class profile::storage::cephosd {
  include ::ceph::profile::osd

  service { 'ceph-osd':
    ensure    => running,
    name      => 'ceph-osd@[0-9]*.service',
    enable    => true,
    provider  => systemd,
    require   => Class[ceph::osds],
  }

  file { '/var/lib/ceph-configured':
    ensure    => file,
    require   => Class[ceph::osds],
    notify    => Exec['initial start of osds'],
  }

  # ceph service must be started once before service status works
  exec { 'initial start of osds':
    command     => '/bin/systemctl start -l ceph-osd.target',
    require     => File['/var/lib/ceph-configured'],
    refreshonly => true,
  }
}
