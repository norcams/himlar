#
class profile::logging::elasticsearch(
  $instances = {},
  $templates = {},
  $indexes   = {},
  $manage_firewall = true,
  $ports = [9200],
  $firewall_extras = {},
  $manage_curator = false
) {

  include ::elasticsearch

  create_resources('elasticsearch::instance', $instances)
  create_resources('elasticsearch::template', $templates)
  create_resources('elasticsearch::index', $indexes)

  if $manage_firewall {
    profile::firewall::rule { '400 elasticsearch accept tcp':
      dport        => $ports,
      destination => $::ipaddress_mgmt1,
      source      => "${::network_mgmt1}/${::netmask_mgmt1}",
      extras      => $firewall_extras,
    }
  }

  if $manage_curator {
    # Curator config
    file { '/root/.curator':
      ensure => directory,
    } ->
    file { '/root/.curator/curator.yml':
      ensure  => file,
      content => template("${module_name}/logging/elasticsearch/curator.yml"),
    }
    # action file
    file { '/var/lib/delete_indices.yml':
      ensure  => file,
      content => template("${module_name}/logging/elasticsearch/delete_indices.yml"),
    }
  }
}
