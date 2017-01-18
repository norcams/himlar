# Profile class for the nova control node
class profile::openstack::novactrl(
  $enable_api           = false,
  $enable_scheduler     = false,
  $enable_consoleauth   = false,
  $enable_consoleproxy  = false,
  $enable_conductor     = false,
  $manage_quotas        = false,
  $manage_az            = false
) {

  include ::nova::config

  if $enable_api {
    include ::profile::openstack::compute::api
  }

  if $enable_scheduler {
    include ::profile::openstack::compute::scheduler
  }

  if $enable_consoleauth {
    include ::profile::openstack::compute::consoleauth
  }

  if $enable_consoleproxy {
    include ::profile::openstack::compute::consoleproxy
  }

  if $enable_conductor {
    include ::profile::openstack::compute::conductor
  }

  if $manage_quotas {
    include ::nova::quota
  }

  if $manage_az {
    include ::nova::availability_zone
  }

}
