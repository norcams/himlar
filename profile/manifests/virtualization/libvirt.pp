#
# class profile::virtualization::libvirt
#
class profile::virtualization::libvirt(
  $networks        = {},
  $pools           = {},
  $manage_firewall = false,
  $firewall_extras = {
    'tcp'      => {},
    'tls'      => {},
    'graphics' => {},
  },
) {
  include ::libvirt

  validate_hash($networks)
  validate_hash($pools)

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
