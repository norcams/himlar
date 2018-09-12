# generate host aggregate
class profile::openstack::resource::host_aggregate() {

  $defaults = {
    metadata => { type => 'standard' },
    require  => Nova::Generic_service['api'],
    notify   => Exec['nova-cell_v2-discover_hosts']
  }

  info('testing aggregate')
  $host_aggregate = lookup('profile::openstack::resource::host_aggregate', Hash, 'deep', {})
  create_resources('nova_aggregate', $host_aggregate, $defaults)

}
