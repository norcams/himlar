#
define profile::development::network::dns_record(
  $use_dnsmasq = false
) {
  $vars = split($name, '\|')
  if $use_dnsmasq {
    host { $vars[0]:
      ip     => $vars[1],
      notify => Class['dnsmasq::reload'],
    }
  } else {
    host { $vars[0]:
      ip => $vars[1]
    }
  }
}
