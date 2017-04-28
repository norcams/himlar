class profile::application::builder (
  $rc_file,
  $template_dir,
  $download_dir,
  $az    = undef,
  $user  = 'imagebuilder',
  $group = 'imagebuilder',
) {

  if $az {
    $real_az = $az
  } else {
    $real_az = "${::location}-default-1"
  }

  file { '/opt/images':
    ensure => directory,
    mode   => '0755'
  } ->
  file { '/opt/images/public_builds':
    ensure => directory,
    mode   => '0755'
  }

  group { $group:
    ensure => present
  } ->
  user { $user:
    ensure     => present,
    managehome => true,
    gid        => $group
  }

  create_resources('profile::application::builder::jobs', hiera_hash('profile::application::builder::images', {}))
}
