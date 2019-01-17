# Class for all things systemd
class profile::base::systemd {

  # Reload systemd
  exec { 'systemctl_daemon_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
