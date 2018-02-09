#
# Author: Michael Chapman <woppin@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   * solarkennedy/consul
#
class profile::application::consul (
  $manage_firewall = true,
  $firewall_extras = {
    'dns'      => {},
    'http'     => {},
    'rpc'      => {},
    'serf-lan' => {},
    'serf-wan' => {},
    'server'   => {}
  },
)
{
  class { "::consul":
#    install_method       => 'package',
    config_defaults      => lookup('consul::config_hash', Hash, 'deep', {}),
    config_hash          => {
      "node_name"        => $::hostname,
      "data_dir"         => "/opt/consul",
      "client_addr"      => "0.0.0.0",
    }
#    config_hash          => {
#      "bootstrap_expect" => 1,
#      "node_name"        => $hostname,
#      "server"           => true,
#      "ui_dir"           => "/opt/consul/ui",
#      "client_addr"      => "0.0.0.0",
#      "advertise_addr"   => $ipaddress_eth0,
#    }
  }

  if $manage_firewall {
    profile::firewall::rule { '190 consul-dns accept tcp':
      port   => 8600,
      extras => $firewall_extras['dns']
    }

    profile::firewall::rule { '191 consul-http accept tcp':
      port   => 8500,
      extras => $firewall_extras['http']
    }

    profile::firewall::rule { '192 consul-rpc accept tcp':
      port   => 8400,
      extras => $firewall_extras['rpc']
    }

    profile::firewall::rule { '193 consul-serf-lan tcp':
      port   => 8301,
      extras => $firewall_extras['serf-lan']
    }

    profile::firewall::rule { '194 consul-serf-wan accept tcp':
      port   => 8302,
      extras => $firewall_extras['serf-wan']
    }

    profile::firewall::rule { '195 consul-server accept tcp':
      port   => 8300,
      extras => $firewall_extras['server']
    }
  }

}
