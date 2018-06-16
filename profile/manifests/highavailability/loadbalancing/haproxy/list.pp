#
define profile::highavailability::loadbalancing::haproxy::list (
  $ips
) {

  file { "/etc/haproxy/${name}.list":
    ensure  => present,
    mode    => '0644',
    content => template("${module_name}/loadbalancing/access_list.erb"),
    notify  => Service['haproxy']
  }

}
