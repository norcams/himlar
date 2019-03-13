# Create new realm
define profile::storage::ceph::realm(
  $manage = true,
  $default = false
) {

  if $manage {
    if $default {
      $default_opt = ' --default'
    } else {
      $default_opt = ''
    }
    exec { "create_ceph_realm-${name}":
      command => "radosgw-admin realm create --rgw-realm=${name} ${default_opt}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => "radosgw-admin realm get | grep ${name}"
    }
  }
}
