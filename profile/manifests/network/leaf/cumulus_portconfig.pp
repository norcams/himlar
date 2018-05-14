  # Define: profile::network::leaf::cumulus_portconfig

  define profile::network::leaf::cumulus_portconfig (
    $ensure           = present,
    $path             = '/etc/cumulus/ports.conf',
    $line             = undef,
    $replace          = true,
  ) {

  file_line {"ports_${name}":
    ensure    => $ensure,
    line      => $line,
    path      => $path,
    match     => "^${name}=.*$",
    replace   => $replace,
  }
}
