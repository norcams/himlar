class profile::dns::rndc_key (
  $create_admin_key    = false,
  $create_mdns_key     = false,
  $host_is_bind_server = false,
  $rndc_secret_admin   = undef,
  $rndc_secret_mdns    = undef
)
{

  if $create_admin_key {
    if $host_is_bind_server {
      file { '/etc/rndc-admin.key':
        content => template("${module_name}/dns/bind/rndc-admin.key.erb"),
        notify  => Service['named'],
        mode    => '0640',
        owner   => 'named',
        group   => 'named',
        require => Package['bind'],
      }
    }
    else {
      file { '/etc/rndc-admin.key':
        content => template("${module_name}/dns/bind/rndc-admin.key.erb"),
        mode    => '0640',
        owner   => 'root',
        group   => 'root',
      }
    }
  }

  if $create_mdns_key {
    if $host_is_bind_server {
      file { '/etc/rndc-mdns.key':
        content => template("${module_name}/dns/bind/rndc-mdns.key.erb"),
        notify  => Service['named'],
        mode    => '0640',
        owner   => 'named',
        group   => 'named',
        require => Package['bind'],
      }
    }
    else {
      file { '/etc/rndc-mdns.key':
        content => template("${module_name}/dns/bind/rndc-mdns.key.erb"),
        mode    => '0640',
        owner   => 'root',
        group   => 'named',
      }
    }
  }
}
