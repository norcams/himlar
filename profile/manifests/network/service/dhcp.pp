#
define profile::network::service::dhcp (
  $subnet,
  $dhcp,
) {
  # Simplify looking up data with an index variable
  $index = delete($name, 'dhcp_')

  if ! empty($dhcp) {
    include dnsmasq

    # Lookup variables
    $d            = $dhcp[$index]
    $s            = $subnet[$index]
    $ensure       = $d['ensure']
    $interface    = $d['interface']
    $gateway      = ip_address($s)
    $start_cidr   = ip_network($s, $d['start_offset'])
    $end_cidr     = ip_network($s, $d['end_offset'])
    $start        = ip_address($start_cidr)
    $end          = ip_address($end_cidr)
    $netmask      = ip_netmask($s)
    $lease        = $d['lease']

    dnsmasq::conf { "${name}-interface":
      ensure  => $ensure,
      content => "interface=${interface}\nbind-interfaces\n",
    }
    dnsmasq::conf { "${name}-option-router":
      ensure  => $ensure,
      content => "dhcp-option=tag:${name},option:router,${gateway}\n",
    }
    dnsmasq::conf { "${name}-dhcp-range":
      ensure  => $ensure,
      content => "dhcp-range=set:${name},${start},${end},${netmask},${lease}\n",
    }
  }

}

