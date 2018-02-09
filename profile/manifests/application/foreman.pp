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
) {

  include ::puppet
  include ::foreman
  include ::foreman_proxy

  include ::foreman::cli
  include ::foreman::compute::libvirt
  include ::foreman::plugin::hooks
  include ::foreman::plugin::discovery
  include ::foreman::plugin::templates

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

  if $manage_repo_dir {
    file { '/opt/repo':
      ensure => directory
    }
  }

  # Push puppet facts to foreman
  $push_facts_ensure = $push_facts? {
    true    => 'present',
    default => 'absent'
  }
  cron { 'push-puppet-facts-to-foreman':
    ensure  => $push_facts_ensure,
    command => '/etc/puppetlabs/puppet/node.rb --push-facts',
    minute  => '30',
    hour    => '*',
  }

  if $manage_firewall {
    profile::firewall::rule { '190 foreman-http accept tcp':
      port   => 80,
      extras => $firewall_extras['http']
    }

    profile::firewall::rule { '191 foreman-https accept tcp':
      port   => 443,
      extras => $firewall_extras['https']
    }

    profile::firewall::rule { '192 foreman-puppet accept tcp':
      port   => 8140,
      extras => $firewall_extras['puppet']
    }

    profile::firewall::rule { '193 foreman-dns accept udp':
      port   => 53,
      proto  => 'udp',
      extras => $firewall_extras['dns']
    }

    profile::firewall::rule { '194 foreman-dns accept tcp':
      port   => 53,
      extras => $firewall_extras['dns']
    }

    profile::firewall::rule { '195 foreman-dhcp accept udp in':
      port   => 67,
      proto  => 'udp',
      extras => $firewall_extras['dhcp']
    }

    profile::firewall::rule { '196 foreman-dhcp accept udp out':
      port   => 68,
      proto  => 'udp',
      chain  => 'OUTPUT',
      extras => $firewall_extras['dhcp']
    }

    profile::firewall::rule { '197 foreman-tftp accept tcp':
      port   => 69,
      proto  => 'udp',
      extras => $firewall_extras['tftp']
    }

    profile::firewall::rule { '197 foreman-proxy accept tcp':
      port   => 8443,
      extras => $firewall_extras['proxy']
    }
  }
}
