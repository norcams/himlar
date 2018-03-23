#
# Openstack Swift proxy class used for storage nodes
#
class profile::openstack::object::proxy(
  $manage_ringserver = false,
  $manage_firewall = false,
  $manage_ceilometer = false,
  $manage_swift3 = false,
  $ring_server = {},
  $firewall_extras = {},
  $test_file = false,
  $proxy_config = {}
) {

  include ::swift
  include ::swift::config
  include ::swift::ringbuilder

  include ::swift::proxy
  include ::swift::proxy::healthcheck
  include ::swift::proxy::cache
  include ::swift::proxy::crossdomain
  include ::swift::proxy::container_sync
  include ::swift::proxy::keystoneauth
  include ::swift::proxy::authtoken
  include ::swift::proxy::dlo
  include ::swift::proxy::slo
  include ::swift::proxy::versioned_writes
  include ::swift::proxy::copy
  include ::swift::proxy::gatekeeper
  include ::swift::proxy::proxy_logging
  include ::swift::proxy::catch_errors

  if $manage_ceilometer {
    # HACK: For some reason the swift::proxy::module need this directory
    file { '/var/log/ceilometer':
      ensure => directory
    }
    include ::swift::proxy::ceilometer
  }

  if $manage_ringserver {
    include ::swift::ringserver
  }

  if $manage_swift3 {
    include ::swift::proxy::swift3
    include ::swift::proxy::s3token
  }

  if $test_file {
    include ::swift::test_file
  }

  # Hack until swift::config also supports proxy config
  create_resources('swift_proxy_config', $proxy_config)

  create_resources('swift::ringsync', $ring_server)

  if $manage_firewall {
    profile::firewall::rule { '250 swift-api accept tcp':
      dport  => 8080,
      extras => $firewall_extras
    }
  }

}
