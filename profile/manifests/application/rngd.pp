#
class profile::application::rngd(
  $enable = false
) {
  if $enable {

      package { 'rng-tools':
        ensure => installed,
      }

      file { '/etc/systemd/system/rngd.service':
        ensure => present,
        mode   => '0644',
        owner  => root,
        group  => root,
        source => "puppet:///modules/${module_name}/common/systemd/rngd.service",
        notify => Exec['daemon reload for rngd']
      }

      exec { 'daemon reload for rngd':
        command     => '/usr/bin/systemctl daemon-reload',
        refreshonly => true,
      }

      service { 'rngd.service':
        ensure => running
      }
  }
}
