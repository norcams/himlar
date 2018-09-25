class profile::openstack::designate (
  $my_zones = {},
  $my_nameservers = {},
  $my_pools = {},
  $my_targets = {},
  $mdns_transport_addr = {},
  $ns_transport_addr = {},
  $ns_public_addr = {},
  $ns_public_name = {},
  $manage_firewall = false,
)
{
  include ::designate
  include ::designate::db
  include ::designate::api
  include ::designate::central
  include ::designate::mdns
  include ::designate::config
  include ::designate::worker
  include ::designate::producer

  file { '/etc/designate/pools.yaml':
    content      => template("${module_name}/openstack/designate/pools.yaml.erb"),
    mode         => '0644',
    owner        => 'root',
    group        => 'root',
    notify       => Exec['fix_designate_pools'],
  }
  exec { 'fix_designate_pools':
    command     => '/usr/bin/designate-manage pool update --file /etc/designate/pools.yaml',
    refreshonly => true,
    require     => Class[designate::db::sync],
  }

  package { 'bind':
    ensure => installed,
  }
  file { '/etc/rndc.conf':
    content      => template("${module_name}/openstack/designate/rndc.conf.erb"),
    mode         => '0640',
    owner        => 'named',
    group        => 'named',
    require      => Package['bind'],
  }

  if $manage_firewall {
    profile::firewall::rule { '001 designate incoming':
      port   => 9001,
      proto  => 'tcp'
    }
    profile::firewall::rule { '002 designate mdns incoming':
      port   => 5354,
      proto  => 'tcp'
    }
  }
}
