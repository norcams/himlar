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

  package { 'uio-google-authenticator':
    provider => 'rpm',
    ensure   => 'installed',
    source   => 'http://rpm.uio.no/uio-free/rhel/7Server/x86_64/uio-google-authenticator-0.3-1.20160314git750d40d.el7.x86_64.rpm'
  }

  pam { 'remove_password':
    ensure  => absent,
    service => 'sshd',
    type    => 'auth',
    control => 'substack',
    module  => 'password-auth',
  }

}
