#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'sensu/sensu'
#
class profile::monitoring::sensu::agent (
  $plugins = {},
  $checks  = {},
) {

  Class['sensu'] -> Sensu::Plugin <||>

  include ::sensu

  create_resources('::sensu::plugin', $plugins)
  create_resources('::sensu::check', $checks)
}
