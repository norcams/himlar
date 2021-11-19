#
define profile::firewall::expand_rule(
  $rule,
  $type
) {

  # HACK: extract the rule name and ip from the define title ($name)
  $name_parts = split($name, '#')
  $rule_name = $name_parts[0]
  $ip = $name_parts[1]

  # Override $type with $name
  $with_source = {
    "${type}" => $ip
  }

  $real_rule = merge($rule, $with_source)
  validate_legacy(Hash, 'validate_hash', $real_rule)

  create_resources('firewall', { "${rule_name} from ${ip}" => $real_rule })
}
