#
define profile::firewall::expand_rule(
  $rule,
  $type,
  $rule_name
) {

  # Override $type with $name
  $with_source = {
    "${type}" => $name
  }

  $real_rule = merge($rule, $with_source)
  validate_hash($real_rule)

  create_resources('firewall', { "${rule_name} from ${name}" => $real_rule })

}
