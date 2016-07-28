# Profile class for the command node
class profile::openstack::command(
  $enable_api           = false,
  $enable_scheduler     = false,
  $enable_consoleauth   = false,
  $enable_consoleproxy  = false,
  $enable_conductor     = false
) {

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
}
