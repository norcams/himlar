#
class profile::monitoring::collectd(
  $enable                    = false,
  $manage_firewall           = false,
  $firewall_extras           = {},
  $merge_strategy            = 'deep'
) {

  if $enable {
    include ::collectd

    # plugins
    $plugins  = lookup('profile::monitoring::collectd::plugins', Array, $merge_strategy, [])
    $plugins.include

  }

}
