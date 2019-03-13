# Setup a mulitsite with realm, zonegroup and zones
class profile::storage::ceph::multisite(
  $manage = false,
  $realms = {},
  $zonegroups = {},
  $zones = {},
  $purge_default = false
) {

  require ::ceph::profile::client

  if $manage {
    create_resources('profile::storage::ceph::realm', $realms)
    create_resources('profile::storage::ceph::zonegroup', $zonegroups)
    create_resources('profile::storage::ceph::zone', $zones)
  }

  if $purge_default {
    file { '/usr/local/sbin/multisite_purge.sh':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/profile/storage/multisite_purge.sh',
    }
    -> exec { 'ceph_multisite_purge_default_zonegroup':
      command => '/usr/local/sbin/multisite_purge.sh && touch /var/lib/ceph/.purge_default_zonegroup',
      creates => '/var/lib/ceph/.purge_default_zonegroup'
    }

  }

}
