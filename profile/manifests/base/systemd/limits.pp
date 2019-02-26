#
# Creates the limits.conf for the service.
# The template uses sections and key/value
#
define profile::base::systemd::limits(
  $service = $name,
  $limits = {}
) {

  # Create a directory for the system unit extras
  file { "/etc/systemd/system/${service}.service.d":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    seltype => 'systemd_unit_file_t',
  }

  # Create the systemd unit extras file, and reload services if appropriate
  $systemd_unit_content = $limits
  file { "/etc/systemd/system/${service}.service.d/limits.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    seltype => 'systemd_unit_file_t',
    content => template("${module_name}/base/systemd-unit.erb"),
    require => File["/etc/systemd/system/${service}.service.d"],
    notify  => [
      Service[$service],
      Exec['systemctl_daemon_reload']
    ],
  }

}
