#
class profile::firewall (
  $rules   = {},
) {

  validate_legacy(Hash, 'validate_hash', $rules)
  create_resources('profile::firewall::rule', $rules)

}
