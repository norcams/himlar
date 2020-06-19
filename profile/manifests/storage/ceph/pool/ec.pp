#
# Create EC profile and pool
#
define profile::storage::ceph::pool::ec(
  $manage               = true,
  $pg_num               = 64,
  $crush_device_class   = 'hdd',
  $crush_root           = 'default',
  $crush_failure_domain = 'host',
  $plugin               = 'jerasure',
  $technique            = 'reed_sol_van',
  $k_data               = 3,
  $m_code               = 2,
  $tag                  = undef,
) {

  require ::ceph::profile::client

  if $manage {
    # Create EC profile
    exec { "create_ceph_ec_profile-${name}":
      command => "ceph osd erasure-code-profile set ${name} crush-root=${crush_root} k=${k_data} \
m=${m_code} plugin=${plugin} technique=${technique} crush-device-class=${crush_device_class} crush-failure-domain=${crush_failure_domain}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => "ceph osd erasure-code-profile get ${name}"
    }
    # Create EC pool
    exec { "create_ceph_ecpool-${name}":
      command => "ceph osd pool create ${name} ${pg_num} ${pg_num} erasure ${name}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => "ceph osd pool stats ${name}"
    }
    # Set application tag
    if $tag {
      exec { "create_ceph_ecpool_set-${name}-tag":
        command => "ceph osd pool application enable ${name} ${tag}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        unless  => "ceph osd pool application get ${name} ${tag}"
      }
    }
  }
}
