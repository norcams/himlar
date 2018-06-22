# Wrapper for package resource to avoid trying to install absent packages
# and only allow ensure present
define profile::base::package (
  $ensure = 'present',
  $provider = undef,
  $source = undef
) {

  unless $ensure == 'absent' {
    package { $name:
      ensure   => 'present',
      provider => $provider,
      source   => $source
    }
  }

}
