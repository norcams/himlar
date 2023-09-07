#
class profile::logging::logrotate(
  Boolean $manage_logrotate = false,
  String $merge_strategy = 'deep',
) {

  if $manage_logrotate {
    include ::logrotate

    # This will apply default rules usually defined in platform
    # Use logrotate::rules in roles to add more rules or
    # set $merge_strategy = first and create a new complete
    # profile::logging::logrotate::rules entry in roles
    $rules  = lookup('profile::logging::logrotate::rules', Hash, $merge_strategy, {})
    create_resources('logrotate::rule', $rules)
  }
}
