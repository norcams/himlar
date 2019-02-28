# This will set custom config to a pool
define profile::storage::ceph::pool::config(
  String $value,
  String $pool,
  String $key = $name,
  Boolean $manage = true,
) {

  require ::ceph::profile::client

  if $manage {
    exec { "ceph_pool_config_${pool}_${key}":
      command => "ceph osd pool set ${pool} ${key} ${value}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => "test $(ceph osd pool get ${pool} ${key} | sed 's/.*:\s*//g') == \"${value}\""
    }
  }

}
