# Node side of the smartctl based disk health check.
#
# This installs smartmontools, the check script and the sudo rule the sensu
# agent needs. The check itself is defined on the sensu backend, see the
# 'smart-check' entry in profile::monitoring::sensu::agent::checks, and is
# only run on agents that subscribe to 'smart'.
#
# Off everywhere by default. Enable per host, or per role once we trust it:
#
#   profile::monitoring::smart::enable: true
#   sensu::agent::subscriptions:
#     - 'base'
#     - 'metrics'
#     - 'physical'
#     - 'smart'
#
# Both are needed. The subscription on its own makes the backend run the check
# on a node where the script was never installed. Set manage_package to false
# where smartmontools is already in profile::base::common::packages, the
# storage role for instance, or the package ends up declared twice.
#
# Thresholds and device selection are per host as well, but are set as sensu
# agent annotations since the check command lives on the backend:
#
#   sensu::agent::annotations:
#     'smart_temp_warning':  '60'
#     'smart_extra_args':    '--exclude /dev/sdz --ignore-error-log'
#
class profile::monitoring::smart (
  Boolean $enable            = false,
  Boolean $manage_package    = true,
  Boolean $manage_sudo       = true,
  Boolean $manage_requiretty = true,
  String  $package_name      = 'smartmontools',
  String  $script_path       = '/usr/local/bin/check_smart.py',
  String  $sensu_user        = 'sensu',
  Integer $sudo_priority     = 26,
) {

  if $enable and ($::runmode == 'default') {

    if $manage_package {
      package { $package_name:
        ensure => present,
      }
    }

    file { $script_path:
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/${module_name}/monitoring/sensugo/checks/check_smart.py",
    }

    if $manage_sudo {
      $requiretty = $manage_requiretty ? {
        true    => ["Defaults:${sensu_user} !requiretty"],
        default => [],
      }

      sudo::conf { 'sensu_smart':
        priority => $sudo_priority,
        content  => $requiretty + ["${sensu_user} ALL = (root) NOPASSWD: ${script_path}"],
      }
    }
  }
}
