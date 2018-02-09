#
class profile::monitoring::sensu::agent (
  $enable_agent = false,
) {

  if $enable_agent {
    include ::sensu

    $gems = lookup('profile::monitoring::sensu::agent::plugin_gems', Hash, 'deep', {})
    $plugins = lookup('profile::monitoring::sensu::agent::plugins', Hash, 'deep', {})
    $checks  = lookup('profile::monitoring::sensu::agent::checks', Hash, 'deep', {})

    create_resources('::sensu::plugin', $plugins)
    create_resources('::sensu::check', $checks)
    create_resources('package', $gems)

  }
}
