# Wrapper for yum group resource
define profile::base::yum_group (
  $ensure = 'present',
) {

  unless $ensure == 'absent' {
    yum::group { $name:
      ensure   => 'present',
      timeout  => 600,
    }
  }
}
