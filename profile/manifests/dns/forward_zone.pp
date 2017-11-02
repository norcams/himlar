define profile::dns::forward_zone($zone, $filename) {
  $internal_zone = $::profile::dns::ns::internal_zone
  file { "/var/named/${filename}":
    content      => template("${module_name}/dns/bind/forward_zone.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'root',
    group        => 'named',
    require      => Package['bind'],
  }
}
