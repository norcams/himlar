#
define profile::development::network::dns_record() {
  $vars = split($name, '\|')
  host { $vars[0]:
    ip => $vars[1]
  }
}
