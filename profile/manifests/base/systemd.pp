#
# Class for all things systemd
#
class profile::base::systemd(
  $manage_limits  = false,
  $limits         = {}
) {

  # Reload systemd
  exec { 'systemctl_daemon_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  if $manage_limits {
    create_resources('profile::base::systemd::limits', $limits)
  }

}
