#
# This will setup the sensu backend services
#
class profile::monitoring::sensu::backend(
  Boolean $manage                 = false,
  Boolean $manage_dashboard       = false,
  Boolean $manage_firewall        = false,
  Array $firewall_ports           = [8081, 3000, 8082],
  Array $firewall_source          = ["${::network_mgmt1}/${::cidr_mgmt1}"],
  Boolean $manage_etcd_firewall   = false,
  Array $firewall_etcd_ports      = [2379,2380],
  Array $firewall_etcd_source     = ["${::network_mgmt1}/${::cidr_mgmt1}"],
  String $merge_strategy          = 'deep',
  String $dashboard_secure        = 'false',
  Integer $dashboard_port         = 3000,
  String $dashboard_api_url       = "https://${::ipaddress_mgmt1}:8082",
  Boolean $enable_bash_completion = false,
  Boolean $purge_asset            = false,
) {

  if $manage {
    include ::sensu::backend
    include ::sensu::cli
    include ::sensu::agent

    $namespace = lookup('sensu_namespace', String, 'first', 'default')
    $defaults = { ensure => present, namespace => $namespace }

    $namespaces = lookup('profile::monitoring::sensu::backend::namespaces', Hash,  $merge_strategy, {})
    $bonsai_assets = lookup('profile::monitoring::sensu::backend::bonsai_assets', Hash, $merge_strategy, {})
    $handlers = lookup('profile::monitoring::sensu::backend::handlers', Hash, $merge_strategy, {})
    $filters  = lookup('profile::monitoring::sensu::backend::filters', Hash, $merge_strategy, {})
    $checks  = lookup('profile::monitoring::sensu::backend::checks', Hash, $merge_strategy, {})

    create_resources('sensu_namespace', $namespaces)
    create_resources('sensu_bonsai_asset', $bonsai_assets, $defaults)
    create_resources('sensu_handler', $handlers, $defaults)
    create_resources('sensu_filter', $filters, $defaults)
    create_resources('sensu_check', $checks, $defaults)

    # purge bonsai asset
    sensu_resources { 'sensu_bonsai_asset':
      purge => $purge_asset,
    }

    # purge checks
    # sensu_resources { 'sensu_check':
    #   purge => $purge_check,
    # }
  }

  if $manage_firewall {
    profile::firewall::rule { '411 sensu accept tcp':
      dport  => $firewall_ports,
      source => $firewall_source,
    }
  }
  if $manage_etcd_firewall {
    profile::firewall::rule { '413 sensu etcd accept tcp':
      dport  => $firewall_etcd_ports,
      source => $firewall_etcd_source,
    }
  }

  if $enable_bash_completion {
    exec { 'sensu-bash-completion':
      command => '/sbin/sensuctl completion bash > /etc/bash_completion.d/sensuctl',
      creates => '/etc/bash_completion.d/sensuctl'
  }

  }
  if $manage_dashboard {
    package { ['yarn', 'sensu-web']:
      ensure => installed,
    }
    file { '/etc/sysconfig/sensu_web':
      ensure  => file,
      content => template("${module_name}/monitoring/sensu/sensu_web.erb"),
    }
    service { 'sensu-web':
      ensure => running,
      enable => true
    }
  }

}
