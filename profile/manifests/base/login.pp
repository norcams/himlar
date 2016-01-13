#
#
class profile::base::login
{
  include googleauthenticator::pam::common

  $pam_modes = hiera('googleauthenticator::pam::mode::modes', {}) 
  if $pam_modes {
    create_resources('googleauthenticator::pam::mode', $pam_modes)
  }

  $pam_modules = hiera('googleauthenticator::pam::modules', {}) 
  if $pam_modules {
    create_resources('googleauthenticator::pam', $pam_modules)
  }

  package { 'norcams-ga':
    provider => 'rpm',
    ensure   => 'installed',
    source   => 'http://folk.uio.no/mikaeld/norcams-ga-0.1.0-0.x86_64.rpm'
  }

  pam { 'remove_password':
    ensure  => absent,
    service => 'sshd',
    type    => 'auth',
    control => 'substack',
    module  => 'password-auth',
  }

}
