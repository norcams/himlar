# Create new zonegroup
define profile::storage::ceph::zonegroup(
  $realm,
  $endpoints,
  $manage = true,
  $master = false,
  $default = false
) {

  if $manage {
    if $default {
      $default_opt = ' --default'
    } else {
      $default_opt = ''
    }
    if $master {
      $master_opt = ' --master'
    } else {
      $master_opt = ''
    }

    exec { "create_ceph_zonegroup-${realm}-${name}":
      command => "radosgw-admin zonegroup create --rgw-zonegroup=${name} --endpoints=${endpoints} --rgw-realm=${realm}${master_opt}${default_opt}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => "radosgw-admin zonegroup list | grep ${name}"
    }

  }

}
