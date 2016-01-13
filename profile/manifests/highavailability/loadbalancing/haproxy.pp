#
# Author: Yanis Guenane <yanis@guenane.org>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/haproxy'
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/concat'
#
class profile::highavailability::loadbalancing::haproxy (
  $haproxy_listens         = {},
  $haproxy_frontends       = {},
  $haproxy_backends        = {},
  $haproxy_balancermembers = {},
  $haproxy_userlists       = {},
  $haproxy_peers           = {},
) {

  include ::haproxy

  create_resources('haproxy::listen', $haproxy_listens)
  create_resources('haproxy::backend', $haproxy_backends)
  create_resources('haproxy::frontend', $haproxy_frontends)
  create_resources('haproxy::balancermember', $haproxy_balancermembers)
  create_resources('haproxy::userlist', $haproxy_userlists)
  create_resources('haproxy::peer', $haproxy_peers)

}
