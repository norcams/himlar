class profile::application::builder (
  $az
) {

  file { '/opt/images/public_builds':
    ensure => directory,
    mode   => '0755'
  }

  create_resources('profile::application::builder::cronjobs', hiera_hash('profile::application::builder::images', {}))
}
