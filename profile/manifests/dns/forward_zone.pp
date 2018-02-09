define profile::dns::forward_zone($zone, $filename) {
  $ns1_public_addr = $::profile::dns::ns::ns1_public_addr

  # Our name servers
  $name_servers = lookup('profile::dns::ns::name_servers', Array, 'deep', [])

  file { "/var/named/${filename}":
    content => template("${module_name}/dns/bind/forward_zone.erb"),
    notify  => Service['named'],
    mode    => '0640',
    owner   => 'root',
    group   => 'named',
    replace => 'no',
    require => Package['bind'],
  }
}
