#
# Use new lvm mechanism to create ceph osds
#
define profile::storage::create_lvm_osd (
  $manage             = true,
  $db_device          = undef,
  $wal_device         = undef,
  $dev_class          = undef, # force device class for osd
  $disable_writecache = undef,
) {

  if $db_device {
    $add_db_device = "--block.db ${db_device}"
  }
  if $wal_device {
    $add_wal_device = "--block.wal ${wal_device}"
  }
  if $manage {
    exec { "zap_disk-${name}":
      command => "/sbin/ceph-volume lvm zap ${name}",
      onlyif  => "/sbin/parted ${name} print | grep \"Partition Table\" | grep gpt",
    } ~>
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
  if $dev_class {
    exec { "set_dev_class-${name}":
      command => "/bin/ceph osd crush rm-device-class $(/sbin/ceph-volume lvm list ${name} | grep ===== | tr --delete =) && /bin/ceph osd crush set-device-class ${dev_class} $(/sbin/ceph-volume lvm list ${name} | grep ===== | tr --delete =)",
      unless  => "/bin/ceph osd crush get-device-class $(/sbin/ceph-volume lvm list ${name} | grep ===== | tr --delete =) | /bin/egrep -x ${dev_class}"
    }
  }
  if $disable_writecache {
    $set_hdparm = {
      "${name}" => { hdparams => '-W0', order => '68', }
    }
    create_resources(profile::base::hdparm, $set_hdparm, {})
    exec { "disable_writecache_now-${name}":
      command     => "hdparm -W0 ${name}",
      path        => '/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      onlyif      => "hdparm -W ${name} | grep on",
    }
  }
}
