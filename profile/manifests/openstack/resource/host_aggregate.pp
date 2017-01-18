# generate host aggregate
class profile::openstack::resource::host_aggregate() {

  $host_aggregate = hiera_hash('profile::openstack::resource::host_aggregate', {})
  create_resources('nova_aggregate', $host_aggregate)

}
