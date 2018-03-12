define profile::dns::forward_zone (
  $zone,
  $filename,
  $ns_a_records = {},
  $ns_aaaa_records = {},
  $delegations = {} )
{
  # Hostmaster email address
  $hostmaster = $::profile::dns::ns::hostmaster

  # Our name servers
  $ns_master = $::profile::dns::ns::ns_master
  $ns_slaves = lookup('profile::dns::ns::ns_slaves', Array, 'deep', [])

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
