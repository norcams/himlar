#
# Author: Yanis Guenane <yanis@guenane.org>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/stdlib'
#   mod 'camptocamp/augeas'
#   mod 'camptocamp/postfix'
#
class profile::mailserver::postfix (
  $configs         = {},
  $hashes          = {},
  $transports      = {},
  $virtuals        = {},
  $manage_firewall = true,
  $firewall_ports  = [25, 587],
  $firewall_extras = {},
) {

  include ::postfix

  create_resources('::postfix::config', $configs)
  create_resources('::postfix::hash', $hashes)
  create_resources('::postfix::transport', $transports)
  create_resources('::postfix::virtual', $virtuals)

  if $manage_firewall {
    profile::firewall::rule { '100 postfix accept tcp 25 587':
      port   => $firewall_ports,
      extras => $firewall_extras
    }
  }

}
