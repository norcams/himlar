#
class profile::application::himlarservice(
  $package_url = undef
) {

  if $package_url {
    package { 'himlarservice':
      ensure   => 'installed',
      provider => 'rpm',
      source   => $package_url,
      notify   => Service['himlarservice-access.service']
    }
  }

  file { '/etc/systemd/system/himlarservice-access.service':
    ensure => present,
    mode   => '0644',
    owner  => root,
    group  => root,
    source => "puppet:///modules/${module_name}/common/systemd/himlarservice-access.service",
    notify => Exec['daemon reload for imlarservice-access']
  }

  exec { 'daemon reload for imlarservice-access':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { 'himlarservice-access.service':
    ensure => running
  }

}
