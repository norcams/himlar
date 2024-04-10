# Wrapper for package resource to avoid trying to install absent packages
# and only allow ensure present
define profile::base::package (
  $ensure = 'present',
  $provider = undef,
  $source = undef,
  $enable_only = undef,
) {

  unless $ensure == 'absent' {
    package { $name:
      ensure      => $ensure,
      provider    => $provider,
      source      => $source,
      enable_only => $enable_only
    }
  }

}
