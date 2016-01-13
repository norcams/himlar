#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/concat'
#   mod 'puppetlabs/apache'
#
class profile::webserver::apache (
  $dev_enable       = false,
  $mods_enable      = [],
  $vhost_definition = {},
  $manage_firewall  = true,
  $firewall_ports   = [80, 443],
  $firewall_extras  = {}
) {

  include ::apache

  if $dev_enable {
    include ::apache::dev
  }

  if !empty($mods_enable) {
    $modules = prefix($mods_enable, '::apache::mod::')
    class { $modules : }
  }

  create_resources('::apache::vhost', $vhost_definition)

  if $manage_firewall {
    profile::firewall::rule { '100 apache accept tcp 80 443':
      port   => $firewall_ports,
      extras => $firewall_extras
    }
  }

}
