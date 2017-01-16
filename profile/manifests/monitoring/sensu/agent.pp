#
class profile::monitoring::sensu::agent (
  $enable_agent = false,
) {

  if $enable_agent {
    include ::sensu

    $gems = hiera_hash('profile::monitoring::sensu::agent::plugin_gems', {})
    $plugins = hiera_hash('profile::monitoring::sensu::agent::plugins', {})
    $checks  = hiera_hash('profile::monitoring::sensu::agent::checks', {})

    create_resources('::sensu::plugin', $plugins)
    create_resources('::sensu::check', $checks)
    create_resources('package', $gems)

  }
}
