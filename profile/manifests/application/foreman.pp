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

    # Remove this after we upgrade to 2.1
    file { 'foreman-systemd-override':
      ensure => absent,
      path   => '/etc/systemd/system/foreman.service.d/override.conf'
    }

}
