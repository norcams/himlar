#
# This will setup ceph pool tiering between to pools
#
define profile::storage::ceph::pool::tier (
  String $storage_pool,
  String $cache_pool,
  Boolean $manage       = true,
  String $cahce_mode    = 'writeback'
) {

  require ::ceph::profile::client

  if $manage {
    exec { "ceph_cache_tier_add-${name}":
      command => "ceph osd tier add ${storage_pool} ${cache_pool}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => "ceph osd pool get ${cache_pool} hit_set_type"
    } ~>
    exec { "ceph_cache_tier_mode-${name}":
      command     => "ceph osd tier cache-mode ${cache_pool} ${cahce_mode}",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      refreshonly => true,
    } ~>
    exec { "ceph_cache_tier_overlay-${name}":
      command     => "ceph osd tier set-overlay ${storage_pool} ${cache_pool}",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      refreshonly => true,
    }
  }

}
