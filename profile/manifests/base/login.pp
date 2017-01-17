#
#

class profile::base::login (
  $manage_db_backup = false,
  $ensure           = 'present',
  $agelimit         = '14',
  $db_servers       = {},
  $repodir          = '/opt/repo/secrets',
  $dump_owner       = '',
  $dump_group       = '',
) {


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
    ensure   => 'installed',
    provider => 'rpm',
    source   => 'http://rpm.uio.no/uio-free/rhel/7Server/x86_64/uio-google-authenticator-0.3-1.20160314git750d40d.el7.x86_64.rpm'
  }

  pam { 'remove_password':
    ensure  => absent,
    service => 'sshd',
    type    => 'auth',
    control => 'substack',
    module  => 'password-auth',
  }

  if $manage_db_backup  {
    $dumpdir        = hiera('profile::database::mariadb::backuptopdir')
    $db_dump_script = hiera('profile::database::mariadb::backupscript')

    create_resources('cron', $db_servers)

    file { 'db-dump.sh':
      ensure  => $ensure,
      path    => '/usr/local/sbin/db-dump.sh',
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/base/db-dump.sh.erb"),
    }

    file { 'db-dump-dir':
      ensure => 'directory',
      path   => '/opt/repo/secrets/dumps',
      mode   => '0775',
      owner  => $dump_owner,
      group  => $dump_group,
    }

  }

}
