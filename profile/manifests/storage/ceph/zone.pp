#
# Create new zone
define profile::storage::ceph::zone(
  $zonegroup,
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

    exec { "create_ceph_zone-${zonegroup}-${name}":
      command => "radosgw-admin zone create --rgw-zonegroup=${zonegroup} \
--rgw-zone=${name} --endpoints=${endpoints}${master_opt}${default_opt}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => "radosgw-admin zone list | grep ${name}"
    }

  }

}
