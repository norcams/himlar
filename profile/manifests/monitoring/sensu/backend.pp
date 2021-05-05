#
# This will setup the sensu backend services
#
class profile::monitoring::sensu::backend(
  Boolean $manage               = false,
  Boolean $manage_dashboard     = false,
  Boolean $manage_firewall      = false,
  Array $firewall_ports         = [8081, 3000, 8082],
  Array $firewall_source        = ["${::network_mgmt1}/${::cidr_mgmt1}"],
  Boolean $manage_etcd_firewall = false,
  Array $firewall_etcd_ports    = [2379,2380],
  Array $firewall_etcd_source   = ["${::network_mgmt1}/${::cidr_mgmt1}"],
  String $merge_strategy        = 'deep',
  String $dashboard_secure      = 'false',
  Integer $dashboard_port       = 3000,
  String $dashboard_api_url     = "https://${::ipaddress_mgmt1}:8082",
  Boolean $purge_check          = false
) {

  if $manage {
    include ::sensu::backend
    include ::sensu::cli
    include ::sensu::agent

    $checks  = lookup('profile::monitoring::sensu::backend::checks', Hash, $merge_strategy, {})
    $namespaces = lookup('profile::monitoring::sensu::backend::namespaces', Hash,  $merge_strategy, {})
    $handlers = lookup('profile::monitoring::sensu::backend::handlers', Hash, $merge_strategy, {})
    $filters  = lookup('profile::monitoring::sensu::backend::filters', Hash, $merge_strategy, {})

    create_resources('sensu_namespace', $namespaces)
    create_resources('sensu_handler', $handlers)
    create_resources('sensu_filter', $filters)
    create_resources('sensu_check', $checks)

    sensu_resources { 'sensu_check':
      purge => $purge_check,
    }
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
