class profile::openstack::loadbalancer (
  $loadbalancer_type = 'haproxy', # possible value haproxy
){

  include "profile::highavailability::${loadbalancer_type}"

}
