#
# Move non-foreman stuff from admin here
#
class profile::application::foreman_proxy (
  $serve_oob_dhcp = false,
) {

  # requires an include statement in role yaml
  if $serve_oob_dhcp {
    file { 'oob_network.conf':
      ensure   => file,
      path     => '/etc/dhcp/oob_network.conf',
      content  => template("${module_name}/application/foreman_proxy/oob_network.conf.erb"),
      notify   => Service['dhcpd'],
    }
  }
}
