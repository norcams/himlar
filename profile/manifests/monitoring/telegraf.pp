# Profile code to enable telegraf

class profile::monitoring::telegraf(
  $enable_telegraf = false,
  $merge_strategy = 'deep',
  ) {

  if $enable_telegraf {
    include ::telegraf

    $defaults = { 'ensure' => present }

    # inputs
    $inputs = lookup('profile::monitoring::telegraf::inputs', Hash, $merge_strategy, {})
    create_resources(telegraf::input, $inputs, $defaults)

    # outputs
    $outputs = lookup('profile::monitoring::telegraf::outputs', Hash, $merge_strategy, {})
    create_resources(telegraf::output, $outputs, $defaults)

  }

}
