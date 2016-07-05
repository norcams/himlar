# Wrapper for package resource to avoid trying to install absent packages
# and only allow ensure present
define profile::base::package (
  $ensure = 'present'
) {

  unless $ensure == 'absent' {
    package { $name:
      ensure => 'present'
    }
  }

}
