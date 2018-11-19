#
#

class profile::base::login (
  $manage_db_backup         = false,
  $manage_repo_incoming_dir = false,
  $forward_oobnet           = false,
  $oob_net                  = '10.0.0.0/24',
  $oob_outiface             = undef,
  $ensure                   = 'present',
  $agelimit                 = '14',
  $db_servers               = {},
  $repodir                  = '/opt/repo',
  $secretsdir               = "${repodir}/secrets",
  $dump_owner               = '',
  $dump_group               = '',
  $repo_incoming_dir        = '/var/lib/repo-incoming',
  $repo_server              = 'iaas-repo.uio.no',
  $yumrepo_path             = '/var/www/html/uh-iaas/yumrepo/',
  $gpg_receiver             = 'UH-IaaS Token Distributor',
  $manage_firewall          = false,
  $manage_dnsmasq           = false,
  $ports                    = [ 53, ],
) {


  include googleauthenticator::pam::common

  $pam_modes = lookup('googleauthenticator::pam::mode::modes', Hash, 'first', {})
  if $pam_modes {
    create_resources('googleauthenticator::pam::mode', $pam_modes)
  }

  $pam_modules = lookup('googleauthenticator::pam::modules', Hash, 'first', {})
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

  file { 'create-gpg.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/create-gpg.sh',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/base/create-gpg.sh.erb"),
  }

  file { [ $repodir, $secretsdir, ]:
      ensure => 'directory',
      mode   => '2775',
      owner  => 'root',
      group  => 'wheel',
    }

  if $manage_db_backup  {
    $dumpdir        = lookup('profile::database::mariadb::backuptopdir', String, 'first', '')
    $db_dump_script = lookup('profile::database::mariadb::backupscript', String, 'first', '')

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
      mode   => '2775',
      owner  => $dump_owner,
      group  => $dump_group,
    }

  }

  file { '/usr/local/sbin/get-oob-ip':
    ensure => present,
    mode   => '0755',
    owner  => root,
    group  => root,
    source => "puppet:///modules/${module_name}/base/get-oob-ip"
  }

  if $manage_repo_incoming_dir {
    package { 'incron':
      ensure => installed
    }

    # Incron entry
    file { '/etc/incron.d/incoming_package':
      ensure  => present,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => template("${module_name}/base/incron/incoming_package.erb"),
      notify  => Service['incrond']
    }

    # Bash script runned by incron
    file { '/usr/local/sbin/update-yumrepo.sh':
      ensure  => present,
      mode    => '0755',
      owner   => root,
      group   => root,
      content => template("${module_name}/base/incron/update-yumrepo.sh.erb")
    }

    service { 'incrond':
      ensure  => running
    }

    file { $repo_incoming_dir:
      ensure => directory,
      mode   => '0775',
      owner  => root,
      group  => wheel
    }
  }

  if $manage_firewall and $manage_dnsmasq {
    profile::firewall::rule { '335 management dns accept tcp':
      dport  => $ports,
      extras => {
        iniface => $::interface_mgmt1,
      },
    }
    profile::firewall::rule { '336 management dns accept udp':
      dport  => $ports,
      proto  => 'udp',
      extras => {
        iniface => $::interface_mgmt1,
      },
    }
  }

  if $forward_oobnet  {
    profile::firewall::rule { '098 postrouting to out-of-band network':
      chain         => 'POSTROUTING',
      proto         => 'all',
      destination   => $oob_net,
      extras => {
        action      => undef,
        jump        => 'MASQUERADE',
        table       => 'nat',
        outiface    => $oob_outiface,
        state       => undef
      }
    }
  }
}
