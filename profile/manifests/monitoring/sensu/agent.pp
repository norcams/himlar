#
class profile::monitoring::sensu::agent (
  $enable_agent = false,
  $plugins = {},
  $checks  = {},
) {

  if $enable_agent {
    include ::sensu

    create_resources('::sensu::plugin', $plugins)
    create_resources('::sensu::check', $checks)
  }
}
