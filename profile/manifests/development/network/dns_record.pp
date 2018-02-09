#
define profile::development::network::dns_record(
  $use_dnsmasq = false
) {
  $vars = split($name, '\|')
  if $use_dnsmasq {
    $notify = $::runmode? { # notify dnsmasq only works in default runmode
      'default' => Class['dnsmasq::reload'],
      default   => undef
    }
    host { $vars[0]:
      ip     => $vars[1],
      notify => $notify
    }
  } else {
    host { $vars[0]:
      ip => $vars[1]
    }
  }
}
