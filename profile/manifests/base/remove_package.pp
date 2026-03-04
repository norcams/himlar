#
# Actively remove installed packages
#
define profile::base::remove_package (
  $ensure = 'absent',
  $provider = undef,
  $source = undef,
  $enable_only = undef,
) {

  package { $name:
    ensure      => absent,
    provider    => $provider,
    source      => $source,
    enable_only => $enable_only
  }
}
