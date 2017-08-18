#
define profile::highavailability::loadbalancing::haproxy::errorpage (
  $code,
  $header,
  $content = '',
  $url = undef
) {

  file { "/etc/haproxy/error.${name}.http":
    ensure  => present,
    mode    => '0644',
    content => template("${module_name}/loadbalancing/error_page.http.erb"),
    notify  => Service['haproxy']
  }
}
