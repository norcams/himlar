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
    profile::firewall::rule { '314 sflow accept udp':
      proto   => udp,
      dport   => 6343,
      iniface => $::ipaddress_trp1,
      extras  => $firewall_extras,
    }
  }

  # Install tools for converting sflow data
  if $manage_sflow2graphite {
    file { 'sflowtool':
      ensure => file,
      path   => '/usr/local/bin/sflowtool',
      source => 'https://iaas-repo.uio.no/uh-iaas/rpm/sflowtool',
      owner  => 'root',
      mode   => '0755',
    }
    file { 'sflow2graphite.pl':
      ensure => file,
      path   => '/usr/sbin/sflow2graphite.pl',
      source => 'https://iaas-repo.uio.no/uh-iaas/rpm/sflow2graphite.pl',
      owner  => 'root',
      mode   => '0755',
    }
  }
}

