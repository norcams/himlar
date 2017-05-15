# Simple setup of IP forwarding and NAT with iptables
class profile::network::nat(
  $enable_masquerade = false,
  $enable_snat = false,
  $iniface = undef,
  $outiface = undef,
  $source = undef,
) {

  # This node is a gw, enable IP fwd
  case $::kernel {
    'Linux': {
      sysctl::value { 'net.ipv4.ip_forward':
      value => 1,
      }
    }
    'FreeBSD': {
      shellvar { "Enable PF for NAT":
        ensure   => present,
        target   => "/etc/rc.conf",
        variable => "pf_enable",
        value    => "YES"
      }
      package { 'bird':
        ensure   => installed
      }
      shellvar { "Enable bird router":
        ensure   => present,
        target   => "/etc/rc.conf",
        variable => "bird_enable",
        value    => "YES"
      }
      file { '/usr/local/etc/bird.conf':
        ensure   => file,
        content  => template("${module_name}/bird/bird-nat.conf.erb"),
        notify   => Service['bird']
      }
      service { 'bird':
        ensure   => running,
        enable   => true,
        require  => Package['bird']
      }
      file { '/etc/pf.conf':
        ensure   => file,
        content  => template("${module_name}/network/pf.conf.erb"),
        notify   => Service['pf']
      }
      service { 'pf':
        ensure   => running,
        enable   => true
      }
    }
    default: {
    }
  }

  if $enable_snat {
    profile::firewall::rule { '099 postrouting with snat':
      chain  => 'POSTROUTING',
      proto  => 'all',
      extras => {
        action   => undef,
        jump     => 'SNAT',
        tosource => $::ipaddress_public1,
        table    => 'nat',
        outiface => $outiface,
        source   => $source,
        state    => undef
      }
    }
  }

  if $enable_masquerade {

    profile::firewall::rule { '099 postrouting with masquerade':
      chain  => 'POSTROUTING',
      proto  => 'all',
      extras => {
        action   => undef,
        jump     => 'MASQUERADE',
        outiface => $outiface,
        source   => $source,
        table    => 'nat',
        state    => undef
      }
    }

    if $iniface and $outiface {
      profile::firewall::rule { "099 forward ${iniface} to ${outiface}":
        chain   => 'FORWARD',
        iniface => $iniface,
        proto   => 'all',
        extras  => {
          outiface => $outiface,
          state    => undef
        }
      }
    }

  }
}
