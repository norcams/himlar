#
# Openstack Swift storage class used for storage nodes
#
class profile::openstack::object::storage(
  Array[String] $ring_object_devices    = [],
  Hash $ring_object_nodes               = {},
  Array[String] $ring_account_devices   = [],
  Hash $ring_account_nodes              = {},
  Array[String] $ring_container_devices = [],
  Hash $ring_container_nodes            = {},
  $loopback = {},
  $disk = {},
  $manage_firewall = false,
  $firewall_extras = {},
  $firewall_ports = ['6000-6002']
) {

  include ::swift
  include ::swift::config

  # Use loopback for testing in vagrant and disk otherwise
  create_resources('swift::storage::loopback', $loopback)
  create_resources('swift::storage::disk', $disk)
  include ::swift::storage::all

  # Object ring devices
  $ring_object_nodes.each |$key, $value| {
    $object_devices = prefix($ring_object_devices, "${key}/")
    ensure_resource('ring_object_device', $object_devices, $value)
  }

  # Container ring devices
  $ring_container_nodes.each |$key, $value| {
    $container_devices = prefix($ring_container_devices, "${key}/")
    ensure_resource('ring_container_device', $container_devices, $value)
  }

  # Account ring devices
  $ring_account_nodes.each |$key, $value| {
    $account_devices = prefix($ring_account_devices, "${key}/")
    ensure_resource('ring_account_device', $account_devices, $value)
  }

  $devices = lookup('swift::storage::all::devices')
  file { $devices:
    ensure => directory
  }

  if $manage_firewall {
    profile::firewall::rule { '251 swift accept tcp':
      dport  => $firewall_ports,
      extras => $firewall_extras
    }
    profile::firewall::rule { '252 rsync accept tcp':
      dport  => 873,
      extras => $firewall_extras
    }

  }

}
