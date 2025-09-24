#
# Class: profile::monitoring::influxdb
#
# This will setup influxdb with the puppet module and manage firewall
#
class profile::monitoring::influxdb(
  String $password,
  String $token,
  String $org,
  String $user,
  Boolean $enable_influxdb  = false,
  Boolean $run_setup        = false,
  Boolean $write_token_file = false,
  # Integer $file_limit      = 32768, #not used
  String $log_level         = 'info',
  Integer $session_length   = 1440,
  String $influxdb_service  = 'influxdb',
  Boolean $manage_firewall  = true,
  Array $firewall_ports     = [8086],
  Array $firewall_source    = ["${::network_mgmt1}/${::cidr_mgmt1}"],
  String $merge_strategy    = 'deep',
  String $setup_extra_options = '--skip-verify'
) {

  if $enable_influxdb {
    include ::influxdb

    $secret_token = Sensitive($token)

    # there is no way to set our token in the influxdb module
    # after the module is finished we overwrite the file with the correct token
    if $write_token_file {
      file { '/root/.influxdb_token':
        ensure  => present,
        content => $token,
        require => Class['influxdb']
      }
    }
    # influx setup in the module require a new token, we disable it and
    # run this manuelly to use our token
    if $run_setup {
      exec { 'influxdb-cli-setup':
        command => @("EOT"/L)
          /bin/influx setup -f \
           --name ${::location} \
           --host https://${::fqdn}:8086 \
           --token ${token} \
           --password ${password} \
           --username ${user} \
           --org ${org} \
           --bucket 'metric' \
           ${setup_extra_options}
          |-EOT
        ,
        creates => '/root/.influxdbv2/configs',
        require => Service[$influxdb_service]
      }
    }

    # this will enable root on ts to run influx cli without authentication
    # exec { 'influxdb-cli-root-user-config':
    #   command => @("EOT"/L)
    #     /bin/influx config create --active \
    #      --config-name ${::location} \
    #      --host-url https://${::fqdn}:8086 \
    #      --token ${token} \
    #      --org ${org}
    #     |-EOT
    #   ,
    #   creates => '/root/.influxdbv2/configs',
    #   require => Service[$influxdb_service]
    # }

    # buckets
    $bucket_defaults = { 'ensure' => present, 'org' => $org, 'token' => $secret_token, require => Exec['influxdb-cli-setup'] }
    $buckets = lookup('profile::monitoring::influxdb::buckets', Hash, $merge_strategy, {})
    create_resources(influxdb_bucket, $buckets, $bucket_defaults)

    # orgs
    $org_defaults = { 'ensure' => present, 'token' => $secret_token, require => Exec['influxdb-cli-setup'] }
    $orgs = lookup('profile::monitoring::influxdb::orgs', Hash, $merge_strategy, {})
    create_resources(influxdb_org, $orgs, $org_defaults)

    # bash completion
    exec { 'influxdb-cli-bash-completion':
      command => '/bin/influx completion bash > /etc/bash_completion.d/influxdb',
      creates => '/etc/bash_completion.d/influxdb'
    }

    # config
    file_line { 'influxdb-log-level':
      ensure => present,
      path   => '/etc/influxdb/config.toml',
      line   => "log-level = \"${log_level}\"",
      match  => '$log-level = ',
      notify => Service[$influxdb_service],
    }

    file_line { 'influxdb-reporting-disabled':
      ensure => present,
      path   => '/etc/influxdb/config.toml',
      line   => 'reporting-disabled = true',
      match  => '$reporting-disabled = ',
      notify => Service[$influxdb_service],
    }

    # session length is set to 24h
    file_line { 'influxdb-session-length':
      ensure => present,
      path   => '/etc/influxdb/config.toml',
      line   => "session-length = ${session_length}",
      match  => '$session-length = ',
      notify => Service[$influxdb_service],
    }

    if $manage_firewall {
      profile::firewall::rule { '417 influxdb accept tcp':
        dport  => $firewall_ports,
        source => $firewall_source,
      }
    }

    #FIXME: the module manages this file so we will need to add this to the module
    # file_line { 'influxdb-file-limits':
    #   ensure => present,
    #   path   => '/etc/systemd/system/influxdb.service.d/override.conf',
    #   line   => "\$LimitNOFILE=${file_limit}",
    #   match  => '$LimitNOFILE=',
    #   notify => Service[$influxdb_service],
    # }
  }

}
