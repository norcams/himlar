# generate host aggregate
class profile::openstack::resource::host_aggregate() {

  $host_aggregate = lookup('profile::openstack::resource::host_aggregate', Hash, 'deep', {})
  create_resources('nova_aggregate', $host_aggregate, { require => Nova::Generic_service['api'] })

}
