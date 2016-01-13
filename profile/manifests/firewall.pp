#
class profile::firewall (
  $rules   = {},
) {

  validate_hash($rules)
  create_resources('profile::firewall::rule', $rules)

}
