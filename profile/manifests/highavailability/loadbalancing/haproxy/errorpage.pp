#
define profile::highavailability::loadbalancing::haproxy::errorpage (
  $code,
  $message = 'Service Unavailable',
  $header = '',
  $content = '',
  $url = undef,
  $format = 'html'
) {

  file { "/etc/haproxy/error.${name}.http":
    ensure  => present,
    mode    => '0644',
    content => template("${module_name}/loadbalancing/error_page.${format}.erb"),
    notify  => Service['haproxy']
  }
}
