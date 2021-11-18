# class: profile::database::galera
#
# Set up galera for replication of mariadb.
# Config goes in mysql::server::override_options
#
# === Parameters
#
# [*wsrep_sst_secure_rsync*]
#   If this is a hash with full path to key, cert and ca secure_rsync with
#   TLS will be an option for wsrep_sst_method i my.conf
#
# [*firewall_rules*]
#   Complete hash with all the rules needed for galere. See default for
#   example. Default are open ports for all!
#
class profile::database::galera(
  $enable_galera_bootstrap = false,
  $manage_mysqld = false,
  $wsrep_sst_secure_rsync = {},
  $manage_firewall = true,
  $firewall_rules = {
    '211 galera accept tcp' => { 'proto' => 'tcp', 'dport' => ['4567', '4568']},
    '212 galera accept udp' => { 'proto' => 'udp', 'dport' => ['4567', '4568']},
    '213 wsrep sst accept tcp' => { 'proto' => 'tcp', 'dport' => '4444'},
  }
) {

  if $manage_mysqld {
    service { 'mysqld':
      ensure  => running,
      require => Anchor['mysql::server::end']
    }
  }

  if $enable_galera_bootstrap {
    exec { 'bootstrap_galera_new_cluster':
      creates => '/root/.galera_boostrap',
      command => '/usr/bin/galera_new_cluster && /bin/sleep 10',
      before  => Class['mysql::server::service'],
      require => Class['mysql::server::installdb'],
      notify  => Exec['touch_galera_bootstrap']
    }
    exec { 'touch_galera_bootstrap':
      command     => '/bin/date > /root/.galera_boostrap',
      refreshonly => true
    }
  }

  if $wsrep_sst_secure_rsync {
    validate_legacy(Hash, 'validate_hash', $wsrep_sst_secure_rsync)
    file { '/usr/bin/wsrep_sst_secure_rsync':
      ensure  => file,
      mode    => '0755',
      content => template("${module_name}/database/wsrep_sst_secure_rsync.erb"),
    }
  }

  if $manage_firewall {
    create_resources('profile::firewall::rule', $firewall_rules)
  }
}
