#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   * puppetlabs/puppetdb
#   * zack/r10k
#   * puppetlabs/inifile
#   * hunner/hiera
#
class profile::application::puppet_master (
  $puppetconf_path      = '/etc/puppet/puppet.conf',
  $hiera_enable         = true,
  $puppetdb_enable      = false,
  $r10k_enable          = false,
  $passenger_enable     = true,
  $main_configuration   = {},
  $agent_configuration  = {},
  $master_configuration = {},
  $user_configuration   = {},
) {

  if $passenger_enable {
    include ::profile::webserver::apache
  }

  if $hiera_enable {
    include ::hiera
  }

  if $r10k_enable {
    include ::r10k
  }

  if $puppetdb_enable {
    include ::puppetdb::master::config
  }

  create_resources('ini_setting', $main_configuration, { 'section' => 'main', 'path' => $puppetconf_path })
  create_resources('ini_setting', $agent_configuration, { 'section' => 'agent', 'path' => $puppetconf_path })
  create_resources('ini_setting', $master_configuration, { 'section' => 'master', 'path' => $puppetconf_path })
  create_resources('ini_setting', $user_configuration, { 'section' => 'user', 'path' => $puppetconf_path })

}
