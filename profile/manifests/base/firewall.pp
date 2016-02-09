#
class profile::base::firewall (
  $manage_firewall        = false,
) {
  if $manage_firewall {
    include ::firewall
    include ::profile::firewall::pre
    include ::profile::firewall::post
    include ::profile::firewall
  }
}
