#
# Create erasure coded pools with corresponding profile
#
# This is a oneshot job pr erasure coded pool
#
define profile::storage::ceph_ecpool (
  $manage               = true,
  $pg_num               = "64",
  $crush_device_class   = "hdd",
  $crush_failure_domain = "host",
  $plugin               = "jerasure",
  $k_data               = "3",
  $m_code               = "2",
  $allow_ec_overwrites  = false,
) {

  require ::ceph::profile::client

  if $manage {
    exec { "create_ceph_ec_profile-${name}":
      command     => "ceph osd erasure-code-profile set ${name} k=${k_data} m=${m_code} crush-device-class=${crush_device_class} crush-failure-domain=${crush_failure_domain} && touch /var/lib/ceph/.${name}-profile-created",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates     => "/var/lib/ceph/.${name}-profile-created",
    } ~>
    exec { "create_ceph_ecpool-${name}":
      command     => "ceph osd pool create ${name} ${pg_num} ${pg_num} erasure ${name}",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      refreshonly => true,
    } ~>
    exec { "set_ceph_ecpool-overwrites_${name}":
      command     => "ceph osd pool set ${name} allow_ec_overwrites ${allow_ec_overwrites}",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      refreshonly => true,
    }
  }
}
