#
# Move non-foreman stuff from admin here
#
class profile::application::foreman_proxy (
  $serve_oob_dhcp = false,
) {

  include ::profile::base::systemd

  # requires an include statement in role yaml
  if $serve_oob_dhcp {
    file { 'oob_network.conf':
      ensure   => file,
      path     => '/etc/dhcp/oob_network.conf',
      content  => template("${module_name}/application/foreman_proxy/oob_network.conf.erb"),
      notify   => Service['dhcpd'],
    }
  }

  # remove custom dhcpd systemd script if it exists
  file { '/etc/systemd/system/dhcpd.service':
    ensure => absent,
    path   => '/etc/systemd/system/dhcpd.service',
    notify  => [
      Exec['systemctl_daemon_reload'],
      Service['dhcpd'],
    ],
  }
}
