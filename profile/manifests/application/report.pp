#
class profile::application::report(
  $package_url        = false,
) {

  if $package_url {
    package { 'report-app':
      ensure   => 'present',
      provider => 'rpm',
      source   => $package_url,
      notify   => Class['apache::service']
    }
  }
}
