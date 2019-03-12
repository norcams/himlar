# Class: profile::storage::cephosd
#
#
class profile::storage::cephosd(
  $create_osds       = false,
  $crush_move        = false,
  $crush_parent      = undef,
  $crush_parent_type = undef,
) {
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

  # Create lvm osds
  if $create_osds {
    $osd_devices = lookup('profile::storage::cephosd::osds', Hash, 'deep', {})
    create_resources('profile::storage::create_lvm_osd', $osd_devices)
  }

  if $crush_move {
    exec { "move_osd_host":
      command     => "ceph osd crush move $(hostname -s) ${crush_parent_type}=${crush_parent} && touch /var/lib/ceph/.host_moved_crush_map",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates     => "/var/lib/ceph/.host_moved_crush_map",
    }
  }
}
