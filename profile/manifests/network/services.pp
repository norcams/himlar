#
class profile::network::services(
  $manage_dhcp        = false,
  $manage_nat         = false,
  $manage_mgmt_nat    = false,
  $manage_dns_records = false,
  $dns_merge_strategy = 'deep',
  $dns_proxy          = false,
  $http_proxy         = false,
  $ntp_server         = false,
  $manage_firewall    = true,
  $firewall_extras    = {}
) {
  $networks = lookup('networks', Hash, 'deep', false)

  if $networks {
    $subnet = $networks[$location]['subnet']
    $dhcp   = $networks[$location]['dhcp']
    $nat    = $networks[$location]['nat']

    if $manage_dhcp {
      include ::dnsmasq
      dnsmasq::conf { 'disable-dns': prio => '01', content => "port=0\n" }

      # Define dhcp ranges per subnet
      $dhcp_keys = keys($dhcp)
      $dhcp_resources = prefix($dhcp_keys, 'dhcp_')
      profile::network::service::dhcp { $dhcp_resources:
        subnet => $subnet,
        dhcp   => $dhcp,
      }
    }

    if $manage_nat {
      # This node is a gw, enable IP fwd
      sysctl::value { 'net.ipv4.ip_forward':
        value => 1,
      }
    }

    if $manage_mgmt_nat {
      # Will set up iptables nat for mgmt based on iniface and outiface from
      # network hash i common/common.yaml
      profile::firewall::rule { '050 snat for mgmt':
        chain  => 'POSTROUTING',
        proto  => 'all',
        extras => {
          action   => undef,
          jump     => 'MASQUERADE',
          outiface => $nat['mgmt']['outiface'],
          table    => 'nat',
          state    => undef
        }
      }
      profile::firewall::rule { '050 forward for mgmt':
        chain   => 'FORWARD',
        iniface => $nat['mgmt']['iniface'],
        proto   => 'all',
        extras  => {
          outiface => $nat['mgmt']['outiface'],
          state    => undef
        }
      }
    }

    if $ntp_server {
      # This node is a ntp-server. Default config is fine, open fw
      if $manage_firewall {
        profile::firewall::rule { '022 ntp-server accept udp':
          dport  => 123,
          proto  => 'udp',
          extras => $firewall_extras
        }
      }
    }

    unless fact('disable_nsupdate') {
      if $manage_dns_records {
        $dns_options = lookup('profile::network::services::dns_options', Hash, $dns_merge_strategy, {})
        $dns_records = lookup('profile::network::services::dns_records', Hash, $dns_merge_strategy, {})
        $record_types = keys($dns_records)

        profile::network::service::dns_record_type { $record_types:
          options => $dns_options,
          records => $dns_records,
        }
      }
    }

    # Enable a dns proxy server
    if $dns_proxy {
      include ::dnsmasq

      if $manage_firewall {
        profile::firewall::rule { '020 dns-proxy accept tcp':
          dport  => 53,
          proto  => 'tcp',
          extras => $firewall_extras
        }
        profile::firewall::rule { '021 dns-proxy accept udp':
          dport  => 53,
          proto  => 'udp',
          extras => $firewall_extras
        }
      }
    }

    # Enable a http proxy server
    if $http_proxy {
      case $::operatingsystemmajrelease {
        '7': {
          include ::tinyproxy
        }
        # el8 does not provide package for tinyproxy, substituted with privoxy
        '8': {
          package { 'privoxy':
            ensure   => installed
          }
          service { 'privoxy':
            ensure   => running,
            enable   => true,
            require  => Package['privoxy']
          }
          file_line {"listen_address":
            ensure   => present,
            line     => "listen-address  ${::ipaddress_mgmt1}:8888",
            path     => "/etc/privoxy/config",
            match    => "^listen-address*",
            replace  => true,
            notify   => Service['privoxy'],
          }
        }
        default: {
          warning("Undefined platform for configuring http proxy!")
        }
      }
      if $manage_firewall {
        profile::firewall::rule { '110 http-proxy accept tcp':
          port   => 8888,
          proto  => 'tcp',
          state  => ['NEW','ESTABLISHED'],
          extras => $firewall_extras
        }
      }
    }
  } else {
    warning("hiera returns no data for 'networks', so we're noop!")
  }
}
