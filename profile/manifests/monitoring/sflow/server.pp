#
class profile::monitoring::sflow::server (
  $manage_sflow2graphite = false,
  $manage_service        = false,
  $manage_firewall       = false,
  $firewall_extras       = undef,
) {

  if $manage_service {
    service { 'sflow-rt':
      ensure => running,
      enable => true
    }
  }

  if $manage_firewall {
    # sFlow collector port
    profile::firewall::rule { '314 sflow accept udp':
      proto   => udp,
      dport   => 6343,
      iniface => $::interface_trp1,
      extras  => $firewall_extras,
    }
    # sFlow collector port
    profile::firewall::rule { '315 sflow-rt http interface accept tcp':
      proto   => tcp,
      dport   => 8008,
      iniface => $::interface_mgmt1,
      extras  => $firewall_extras,
    }
  }

  # Install tools for converting sflow data
  if $manage_sflow2graphite {
    file { 'sflowtool':
      ensure => file,
      path   => '/usr/local/bin/sflowtool',
      source => 'https://iaas-repo.uio.no/nrec/rpm/sflowtool',
      owner  => 'root',
      mode   => '0755',
    }
    file { 'sflow2graphite.pl':
      ensure => file,
      path   => '/usr/sbin/sflow2graphite.pl',
      source => 'https://iaas-repo.uio.no/nrec/rpm/sflow2graphite.pl',
      owner  => 'root',
      mode   => '0755',
    }
  }
}

