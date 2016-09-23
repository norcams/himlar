#
class profile::monitoring::sensu::agent (
  $enable_agent = false,
  $plugins = {},
  $checks  = {},
) {

  include ::sensu

  create_resources('::sensu::plugin', $plugins)
  create_resources('::sensu::check', $checks)
}
