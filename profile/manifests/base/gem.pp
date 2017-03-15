# Wrapper for gem resource to avoid trying to install absent gems
# and only allow ensure present
define profile::base::gem (
  $ensure = 'present'
) {

  unless $ensure == 'absent' {
    package { $name:
      ensure   => 'present',
      provider => 'gem'
    }
  }
}
