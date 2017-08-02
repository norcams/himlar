# Manage Galera Arbitrator
class profile::database::galera::arbitrator(
  $manage_arbitrator = false,
  $manage_firewall   = false,
  $firewall_rules = {
    '211 galera accept tcp' => { 'proto' => 'tcp', 'dport' => ['4567', '4568']},
    '212 galera accept udp' => { 'proto' => 'udp', 'dport' => ['4567', '4568']},
  }
) {

  if $manage_arbitrator {
    include ::galera_arbitrator
  }

  if $manage_firewall {
    create_resources('profile::firewall::rule', $firewall_rules)
  }

}
