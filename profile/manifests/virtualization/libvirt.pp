#
# class profile::virtualization::libvirt
#
class profile::virtualization::libvirt(
  Boolean $manage_firewall = false,
  Boolean $moduler_daemons = false,
  String $merge_strategy = 'deep',
  String $libvirt_tcp_listen = "${::ipaddress_mgmt1}:16509",
  $firewall_extras = {
    'tcp'      => {},
    'tls'      => {},
    'graphics' => {},
  },
) {
  include ::libvirt

  if $moduler_daemons {
    # raykrist: This will need a fork of systemd module. Drop for now
    # set listen ip/port
    # systemd::manage_dropin { 'override.conf':
    #   ensure       => present,
    #   unit         => 'virtproxyd-tcp.socket',
    #   show_diff    => true,
    #   socket_entry => {
    #     'ListenStream' => ['', $libvirt_tcp_listen]
    #   },
    #   unit_entry   => {
    #     'After' => 'network-online.target'
    #   },
    #   before       => Service['virtproxyd-tcp.socket']
    # }

    file_line { 'disable auth for virtproxyd tcp socket':
      path   => '/etc/libvirt/virtproxyd.conf',
      line   => 'auth_tcp = "none"',
      match  => '^#auth_tcp = "sasl"',
      before => Service['virtproxyd-tcp.socket']
    }
  }

  $networks = lookup('profile::virtualization::libvirt::networks', Hash, $merge_strategy, {})
  $pools = lookup('profile::virtualization::libvirt::pools', Hash, $merge_strategy, {})

  create_resources('::libvirt::network', $networks)
  create_resources(libvirt_pool, $pools)

  if $manage_firewall {
    profile::firewall::rule { '180 libvirt-tcp accept tcp':
      dport  => 16509,
      source => "${::network_mgmt1}/${::netmask_mgmt1}",
      extras => $firewall_extras['tcp']
    }

    profile::firewall::rule { '181 libvirt-tls accept tcp':
      dport  => 16514,
      source => "${::network_mgmt1}/${::netmask_mgmt1}",
      extras => $firewall_extras['tls']
    }

    profile::firewall::rule { '182 libvirt-graphics console accept tcp':
      dport  => '5900-5999',
      source => "${::network_mgmt1}/${::netmask_mgmt1}",
      extras => $firewall_extras['graphics']
    }
  }
}
