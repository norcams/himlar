# Custom config to ceph.conf
class profile::storage::ceph::config(
  $manage_config = false,
  $config = {}
) {

  require ::ceph::profile::client

  if $manage_config {
    create_resources('ceph_config', $config)
  }

}
