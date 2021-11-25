  # Define: profile::network::leaf::cumulus_portconfig

  define profile::network::leaf::switchd_config (
    $ensure           = present,
    $path             = '/etc/cumulus/switchd.conf',
    $line             = undef,
    $replace          = true,
  ) {

  file_line {"switcdconf_${name}":
    ensure    => $ensure,
    line      => $line,
    path      => $path,
    match     => "^${name} = .*$",
    replace   => $replace,
  }
}
