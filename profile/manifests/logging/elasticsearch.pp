#
class profile::logging::elasticsearch(
  $instances = {},
  $templates = {},
  $indexes   = {},
  $manage_firewall = true,
  $ports = [9200],
  $firewall_extras = {},
  $manage_curator = false,
  $manage_replicas = true,
  $manage_shards = true
) {

  include ::elasticsearch

  create_resources('elasticsearch::instance', $instances)
  create_resources('elasticsearch::template', $templates)
  create_resources('elasticsearch::index', $indexes)

  if $manage_firewall {
    profile::firewall::rule { '400 elasticsearch accept tcp':
      port        => $ports,
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
    file { '/root/delete_indices.yml':
      ensure  => file,
      content => template("${module_name}/logging/elasticsearch/delete_indices.yml"),
    }
  }

  if $manage_replicas {
    file_line { 'index_replicas':
      ensure    => absent,
      path      => '/etc/elasticsearch/openstack/elasticsearch.yml',
      match     => '^index.number_of_replicas*',
      match_for_absence => true,
      multiple  => true,
    }
  }

  if $manage_shards {
    file_line { 'index_shards':
      ensure     => absent,
      path       => '/etc/elasticsearch/openstack/elasticsearch.yml',
      match      => '^index.number_of_shards*',
      match_for_absence => true,
      multiple   => true,
    }
  }
}
