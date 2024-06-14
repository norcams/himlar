#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'yguenane/mariadbrepo'
#   mod 'puppetlabs/mysql'
#   mod 'nanliu/staging'
#   mod 'puppetlabs/stdlib
#
class profile::database::mariadb (
  $dbs             = {},
  $databases       = {},
  $users           = {},
  $grants          = {},
  $plugins         = {},
  $client_enabled  = true,
  $manage_repo     = true,
  $manage_firewall = true,
  $firewall_extras = {},
  $packages        = [],

  $backupuser                   = '',
  $backuppassword_unsensitive   = '',
  $backupmethod                 = 'mysqldump',
  $backuptopdir                 = '/var/db/dumps',
  $backupscript                 = '',
  $backupdirmode                = '0744',
  $backupdirowner               = 'root',
  $backupdirgroup               = 'root',
  $backupcompress               = true,
  $backuprotate                 = 5,
  $backup_success_file_path     = '/var/db/dumps/db_dumped.flag',
  $maxallowedpacket             = 1024,
  $ignore_events                = true,
  $delete_before_dump           = false,
  $backupdatabases              = [],
  $file_per_database            = false,
  $include_triggers             = false,
  $include_routines             = false,
  $ensure                       = 'present',
  $prescript                    = false,
  $postscript                   = false,
  $execpath                     = '/usr/bin:/usr/sbin:/bin:/sbin',
) {

  $backupdir = "${backuptopdir}/${::hostname}"

  if $manage_repo {
    include ::mariadbrepo
  }

  package { $packages:
    ensure => installed,
    before => Class['mysql::server']
  }

  include ::mysql::server
  create_resources('mysql::db', $dbs)
  create_resources('mysql_database', $databases)
  create_resources('mysql_user', $users)
  create_resources('mysql_grant', $grants)

  if $client_enabled {
    include ::mysql::client
  }

  if $manage_firewall {
    profile::firewall::rule { '200 mysql accept tcp':
      dport  => 3306,
      extras => $firewall_extras
    }
  }

  file { 'mysqlbackup.sh':
    ensure  => $ensure,
    path    => $backupscript,
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mysql/mysqlbackup.sh.erb'),
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

  file { '/var/db/dumps':
    ensure => 'directory',
  }
}
