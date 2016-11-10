# Profile class for the nova control node
class profile::openstack::resource::quotas (
  $manage_compute       = false,
  $manage_network       = false,
  $manage_volume        = false,
  $quota_instances      = '10',
  $quota_cores          = '20',
  $quota_ram            = '51200',
) {

  if $manage_compute {
    include ::nova::quota
  }
}
