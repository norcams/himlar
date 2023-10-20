#
class profile::monitoring::collectd(
  $enable                    = false,
  $manage_firewall           = false,
  $manage_service            = false, # use when service name is not collectd
  $service_name              = undef,
  $service_ensure            = running,
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
      content => "[Service]\nCapabilityBoundingSet=CAP_DAC_OVERRIDE CAP_SYS_ADMIN CAP_NET_ADMIN\n",
      notify  => [Exec['systemctl_daemon_reload'], Service['collectd']]
    }

  }

  if $manage_service {
    service { $service_name:
      ensure => $service_ensure,
      enable => true
    }
  }
}
