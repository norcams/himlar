class profile::rhsm::virtwho (
  $manage = false
) {

  if $manage {

    $owner               = lookup('uio_satellite_organization', String, 'first', '')
    $rhsm_hostname       = lookup('uio_satellite_server', String, 'first', '')
    $rhsm_username       = lookup('uio_satellite_virtwho_username', String, 'first', '')
    $rhsm_password       = lookup('uio_satellite_virtwho_password', String, 'first', '')
    $rhsm_proxy_hostname = lookup('::subscription_manager::config_hash::server_proxy_hostname', String, 'first', '')
    $rhsm_proxy_port     = lookup('::subscription_manager::config_hash::server_proxy_port', String, 'first', '')

    package { 'virt-who':
      ensure => installed,
    }

    file { '/etc/virt-who.d/nrec.conf':
      content => template("${module_name}/rhsm/virt-who.conf.erb"),
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['virt-who'],
    }

    service { 'virt-who':
      ensure  => running,
      enable  => true,
      require => [
        File['/etc/virt-who.d/nrec.conf']
      ],
    }

  }

}
