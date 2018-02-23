define profile::dns::reverse_zone($cidr, $origin, $filename) {

  # Hostmaster email address
  $hostmaster = $::profile::dns::ns::hostmaster

  # Our name servers
  $ns_master = $::profile::dns::ns::ns_master
  $ns_slaves = lookup('profile::dns::ns::ns_slaves', Array, 'deep', [])

  file { "/var/named/${filename}":
    content => template("${module_name}/dns/bind/reverse_zone.erb"),
    notify  => Service['named'],
    mode    => '0640',
    owner   => 'root',
    group   => 'named',
    replace => 'no',
    require => Package['bind'],
  }
}
