#
class profile::monitoring::collectd(
  $enable                    = false,
  $manage_firewall           = false,
  $firewall_extras           = {},
  $merge_strategy            = 'deep'
) {

  if $enable {
    include ::collectd
    include ::profile::base::systemd

    # plugins
    $plugins  = lookup('profile::monitoring::collectd::plugins', Array, $merge_strategy, [])
    $plugins.include

    file { 'collectd-systemd-dir':
      ensure => directory,
      path   => '/etc/systemd/system/collectd.service.d/',
      owner  => root,
      group  => root,
    }
    -> file { 'collectd-systemd-override':
      ensure  => file,
      path    => '/etc/systemd/system/collectd.service.d/override.conf',
      owner   => root,
      group   => root,
      content => "[Service]\nCapabilityBoundingSet=CAP_DAC_OVERRIDE\n",
      notify  => [Exec['systemctl_daemon_reload'], Service['collectd']]
    }

  }

}
