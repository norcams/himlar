# Setup a ceph pool
class profile::storage::ceph::pool (
  Hash $tiers       = {},
  Hash $crush_rules = {}
) {

  require ::ceph::profile::client

  create_resources('profile::storage::ceph_crushrules', $crush_rules)

  # This is deep merge, when overriding hieradata use ensure: absent to drop pool
  $pools = lookup('profile::storage::ceph::pool::pools', Hash, 'deep')
  $pools.each |String $name, Hash $data| {
    $real_data = delete($data, 'custom')
    # Create pool
    create_resources('ceph::pool', { $name => $real_data })
    # Pool custom config
    if $data['custom'] and $data['present'] != 'absent' {
      $data['custom'].each |String $key, String $value| {
        $custom = { 'pool' => $name, 'key' => $key, 'value' => $value }
        create_resources('profile::storage::ceph::pool::config', { "${name}-${key}" =>  $custom })
      }
    }
  }

  # This is deep merge, when overriding hieradata use ensure: absent to drop ec pool
  $ec_pools = lookup('profile::storage::ceph::pool::ec_pools', Hash, 'deep')
  info($ec_pools)
  $ec_pools.each |String $name, Hash $data| {
    $real_data = delete($data, 'custom')
    # Create EC pool
    create_resources('profile::storage::ceph::pool::ec', { $name => $real_data })
    # Pool custom config
    if $data['custom'] and $data['present'] != 'absent' {
      $data['custom'].each |String $key, String $value| {
        $custom = { 'pool' => $name, 'key' => $key, 'value' => $value }
        create_resources('profile::storage::ceph::pool::config', { "${name}-${key}" =>  $custom })
      }
    }
  }

  # This will setup the tiering and set custom config for the cache pool only
  $tiers.each |String $name, Hash $data| {
    $real_data = delete($data, 'custom')
    # Create pool
    create_resources('profile::storage::ceph::pool::tier', { $name => $real_data })
    # Pool custom config
    if $data['custom'] and $data['present'] != 'absent' {
      $data['custom'].each |String $key, String $value| {
        $custom = { 'pool' => $data['cache_pool'], 'key' => $key, 'value' => $value }
        create_resources('profile::storage::ceph::pool::config', { "${name}-${key}" =>  $custom })
      }
    }
  }

}
