# Class to reload systemd
class profile::base::systemd::daemon_reload {
  exec { 'norcams_systemctl_daemon_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
