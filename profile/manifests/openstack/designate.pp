class profile::openstack::designate (
  $manage_firewall = false,
  $bind_servers = {}
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

  $bind_servers = lookup('profile::openstack::designate::bind_servers', Hash, 'first', {})

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
    profile::firewall::rule { '002 TCP designate mdns incoming':
      port   => 5354,
      proto  => 'tcp'
    }
    profile::firewall::rule { '003 UDP designate mdns incoming':
      port   => 5354,
      proto  => 'udp'
    }
  }
}
