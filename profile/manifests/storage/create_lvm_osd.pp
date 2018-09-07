#
# Use new lvm mechanism to create ceph osds
#
define profile::storage::create_lvm_osd (
  $manage      = true,
  $db_device   = undef,
  $wal_device  = undef,
) {

  if $db_device {
    $add_db_device = "--block.db ${db_device}"
  }
  if $wal_device {
    $add_wal_device = "--block.wal ${wal_device}"
  }
  # Create the osds
  if $manage {
    exec { "create_lvm_osd-${name}":
      command => "/sbin/ceph-volume lvm create --bluestore ${add_db_device} ${add_wal_device} --data ${name}",
      unless  => "/sbin/ceph-volume lvm list ${name} | grep ====== >/dev/null 2>&1",
    }
    # Ensure that the osd service is running
    exec { "osd-service-${name}":
      command => "/bin/systemctl start ceph-osd@$(/sbin/ceph-volume lvm list ${name} | grep 'osd id' | grep -Eo '[0-9]{1,40}').service",
      onlyif  => "/bin/systemctl status ceph-osd@$(/sbin/ceph-volume lvm list ${name} | grep 'osd id' | grep -Eo '[0-9]{1,40}') | grep inactive",
    }
  }
}
