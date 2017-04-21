#
class profile::base::firewall (
  $manage_firewall        = false,
  $purge_firewall         = false
) {
  if $manage_firewall {
    if $::osfamily == 'FreeBSD' {
    } else {
      if $purge_firewall {
        resources { 'firewall':
          purge => true
        }
      }
      include ::firewall
      include ::profile::firewall::pre
      include ::profile::firewall::post
      include ::profile::firewall
    }
  }
}
