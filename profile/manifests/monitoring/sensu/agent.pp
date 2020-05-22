#
class profile::monitoring::sensu::agent (
  $enable_agent = false,
  Boolean $run_in_vrf = false,
  String $merge_strategy = 'deep'
) {

  if $enable_agent {
    include ::sensu

    $gems = lookup('profile::monitoring::sensu::agent::plugin_gems', Hash, $merge_strategy, {})
    $plugins = lookup('profile::monitoring::sensu::agent::plugins', Hash, $merge_strategy, {})
    $checks  = lookup('profile::monitoring::sensu::agent::checks', Hash, $merge_strategy, {})

    create_resources('::sensu::plugin', $plugins)
    create_resources('::sensu::check', $checks)
    create_resources('package', $gems)

    # this is used for cumulus linux (debian)
    if $run_in_vrf {

      file { 'sensu-systemd-dir':
        ensure => directory,
        path   => '/etc/systemd/system/sensu-client.service.d/',
        owner  => root,
        group  => root,
      }
      -> file { 'sensu-systemd-override':
        ensure => file,
        path   => '/etc/systemd/system/sensu-client.service.d/override.conf',
        owner  => root,
        group  => root,
        source => "puppet:///modules/${module_name}/monitoring/sensu/systemd/override.conf",
        notify => [Exec['debian_systemctl_daemon_reload'], Service['sensu-client']]
      }

      exec { 'debian_systemctl_daemon_reload':
        command     => '/bin/systemctl daemon-reload',
        refreshonly => true,
      }
    }

  }
}
