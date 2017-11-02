define profile::dns::forward_zone($zone, $filename) {

  # Our name servers
  $name_servers = hiera_array('profile::dns::ns::name_servers', {})

  file { "/var/named/${filename}":
    content      => template("${module_name}/dns/bind/forward_zone.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'root',
    group        => 'named',
    replace      => 'no',
    require      => Package['bind'],
  }
}
