class profile::openstack::designate (
  $manage_firewall = false
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
  include ::designate::quota
  include ::designate::wsgi::apache

  $bind_servers = lookup('profile::openstack::designate::bind_servers', Hash, 'first', {})

  file { '/etc/designate/pools.yaml':
    content      => template("${module_name}/openstack/designate/pools.yaml.erb"),
    mode         => '0644',
    owner        => 'root',
    group        => 'root',
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
    $ns_sources_ipv4 = lookup('profile::openstack::designate::ns_sources_ipv4', Array, 'unique', ['127.0.0.1/8'])
    $ns_sources_ipv6 = lookup('profile::openstack::designate::ns_sources_ipv6', Array, 'unique', ['::1/128'])
    profile::firewall::rule { '001 designate incoming':
      port   => 9001,
      proto  => 'tcp'
    }
    profile::firewall::rule { '002 TCP designate mdns incoming':
      port   => 5354,
      proto  => 'tcp',
      source => $ns_sources_ipv4
    }
    profile::firewall::rule { '003 UDP designate mdns incoming':
      port   => 5354,
      proto  => 'udp',
      source => $ns_sources_ipv4
    }
    profile::firewall::rule { '002 TCP designate mdns incoming IPv6':
      port     => 5354,
      proto    => 'tcp',
      provider => 'ip6tables',
      source   => $ns_sources_ipv6
    }
    profile::firewall::rule { '003 UDP designate mdns incoming IPv6':
      port     => 5354,
      proto    => 'udp',
      provider => 'ip6tables',
      source   => $ns_sources_ipv6
    }
  }
}
