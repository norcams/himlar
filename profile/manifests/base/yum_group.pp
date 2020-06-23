# Install yum group
define profile::base::yum_group (
  $ensure = 'present',
) {

  unless $ensure == 'absent' {
    exec { "install-${name}":
      command => "yum groupinstall -y ${name}",
      path    => '/usr/bin:/usr/sbin:/bin',
      refreshonly => true,
    }
  }
}
