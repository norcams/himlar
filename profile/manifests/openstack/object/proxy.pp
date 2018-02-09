#
# Openstack Swift proxy class used for storage nodes
#
class profile::openstack::object::proxy(
  $manage_ringserver = false,
  $manage_firewall = false,
  $ring_server = {},
  $firewall_extras = {},
  $test_file = false
) {

  include ::swift

  include ::swift::ringbuilder

  include ::swift::proxy
  include ::swift::proxy::healthcheck
  include ::swift::proxy::cache
  include ::swift::proxy::container_sync
  include ::swift::proxy::keystone
  include ::swift::proxy::authtoken
  include ::swift::proxy::dlo
  include ::swift::proxy::versioned_writes
  include ::swift::proxy::copy
  include ::swift::proxy::gatekeeper
  include ::swift::proxy::proxy_logging
  include ::swift::proxy::catch_errors

  if $manage_ringserver {
    include ::swift::ringserver
  }

  if $test_file {
    include ::swift::test_file
  }

  create_resources('swift::ringsync', $ring_server)

  if $manage_firewall {
    profile::firewall::rule { '250 swift-api accept tcp':
      dport  => 8080,
      extras => $firewall_extras
    }
  }

}
