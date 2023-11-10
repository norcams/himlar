#
# This class does nothing unless sensu agent is enabled!
#
class profile::monitoring::sensu::mysql(
  $password,
  $user            = 'sensu',
  $host            = 'localhost',
  $manage_packages = false
) {

  # Do nothing if agent is not enabled
  $enable_agent = lookup('profile::monitoring::sensu::agent::enable_agent', Boolean, 'first', false)

  if $enable_agent {
    mysql_user { "${user}@${host}":
      ensure                   => 'present',
      password_hash            => mysql_password($password),
      max_connections_per_hour => '0',
      max_queries_per_hour     => '0',
    }

    file { '/etc/sensu/conf.d/mysql.ini':
      ensure  => file,
      content => template("${module_name}/monitoring/sensu/mysql.ini.erb"),
      require => Class['profile::monitoring::sensu::agent']
    }

  } else {
    info('sensu agent disabled for mysql')
  }

  # Do nothing if agent is not enabled
  $enable_go_agent = lookup('profile::monitoring::sensu::agent::enable_go_agent', Boolean, 'first', false)

  if $enable_go_agent {
    mysql_user { "${user}@${host}":
      ensure                   => 'present',
      password_hash            => mysql_password($password),
      max_connections_per_hour => '0',
      max_queries_per_hour     => '0',
    }

    file { '/etc/sensu/mysql.ini':
      ensure  => file,
      content => template("${module_name}/monitoring/sensu/mysql.ini.erb"),
      require => Class['profile::monitoring::sensu::agent']
    }

  } else {
    info('sensu agent disabled for mysql')
  }
}
