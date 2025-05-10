#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'theforeman/foreman'
#   mod 'theforeman/foremam_proxy'
#   mod 'theforeman/puppet'
#   mod 'theforeman/tftp'
#   mod 'zack/r10k'
#   mod 'ghoneycutt/eyaml
#
class profile::application::foreman(
  $manage_eyaml    = false,
  $manage_r10k     = false,
  $manage_firewall = false,
  $manage_repo_dir = false,
  $firewall_extras = {
    'http'   => {},
    'https'  => {},
    'puppet' => {},
    'dns'    => {},
    'dhcp'   => {},
    'tftp'   => {},
    'proxy'  => {},
  },
  $push_facts      = false,
  Hash $dhcp_classes = {},
  $repo_owner = 'root',
  $repo_group = 'root',
  $repo_mode = '0755'
) {

  # FIX: start foreman-proxy after setting correct acl for /etc/dhcpd
  Class['foreman_proxy::proxydhcp'] -> Class['foreman_proxy::service']

  include ::puppet
  include ::foreman
  include ::foreman_proxy

  include ::foreman::cli
  include ::foreman::compute::libvirt
  include ::foreman::plugin::hooks
  include ::foreman::plugin::discovery
  include ::foreman::plugin::templates
  include ::foreman::plugin::puppet

  if $manage_r10k {
    include ::r10k
    file { '/etc/puppetlabs':
      ensure => directory,
      before => Class['r10k']
    }
  }

  if $manage_eyaml {
    include ::eyaml
  }

  # future-proof this folder so we can use wheel group
  if $manage_repo_dir {
    file { '/opt/repo':
      ensure => directory,
      owner  => $repo_owner,
      group  => $repo_group,
      mode   => $repo_mode
    }
  }

  # config
  $config = lookup('profile::application::foreman::config', Hash, 'deep', {})
  create_resources('foreman_config_entry', $config, { require => Class['foreman']})

  # plugins
  $plugins = lookup('profile::application::foreman::plugins', Hash, 'deep', {})
  create_resources('foreman::plugin', $plugins)

  create_resources('dhcp::dhcp_class', $dhcp_classes)

  # Push puppet facts to foreman
  $push_facts_ensure = $push_facts? {
    true    => 'present',
    default => 'absent'
  }
  cron { 'push-puppet-facts-to-foreman':
    ensure  => $push_facts_ensure,
    command => '/etc/puppetlabs/puppet/node.rb --push-facts > /dev/null 2>&1',
    minute  => '30',
    hour    => '0',
  }

  if $manage_firewall {
    profile::firewall::rule { '190 foreman-http accept tcp':
      dport  => 80,
      extras => $firewall_extras['http']
    }

    profile::firewall::rule { '191 foreman-https accept tcp':
      dport  => 443,
      extras => $firewall_extras['https']
    }

    profile::firewall::rule { '192 foreman-puppet accept tcp':
      dport  => 8140,
      extras => $firewall_extras['puppet']
    }

    profile::firewall::rule { '193 foreman-dns accept udp':
      dport  => 53,
      proto  => 'udp',
      extras => $firewall_extras['dns']
    }

    profile::firewall::rule { '194 foreman-dns accept tcp':
      dport  => 53,
      extras => $firewall_extras['dns']
    }

    profile::firewall::rule { '195 foreman-dhcp accept udp in':
      dport  => 67,
      proto  => 'udp',
      extras => $firewall_extras['dhcp']
    }

    profile::firewall::rule { '196 foreman-dhcp accept udp out':
      dport  => 68,
      proto  => 'udp',
      chain  => 'OUTPUT',
      extras => $firewall_extras['dhcp']
    }

    profile::firewall::rule { '197 foreman-tftp accept tcp':
      dport  => 69,
      proto  => 'udp',
      extras => $firewall_extras['tftp']
    }

    profile::firewall::rule { '197 foreman-proxy accept tcp':
      dport  => 8443,
      extras => $firewall_extras['proxy']
    }
  }
}
