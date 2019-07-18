# Define: profile::base::lvm_config
#
define profile::base::lvm_config (
  $ensure           = present,
  $path             = '/etc/lvm/lvm.conf',
  $line             = undef,
  $replace          = true,
  $match            = undef,
) {

  file_line {"types_${name}":
    ensure    => $ensure,
    line      => $line,
    path      => $path,
    match     => $match,
    replace   => $replace,
  }
}
