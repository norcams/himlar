#
# Wrapper for custom firewall rules.
# Each entry in profile::firwall::rules::custom_rules are passed to
# the profile::firwall::rule define.
#
class profile::firewall::rules (
  $manage_custom_rules = false
) {

  if $manage_custom_rules {
    info('custom rules')
    $rules = lookup('profile::firewall::rules::custom_rules', Hash, 'deep', {})
    create_resources('profile::firewall::rule', $rules)
  }

}
