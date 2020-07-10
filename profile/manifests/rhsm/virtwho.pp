class profile::rhsm::virtwho (
  $manage = false
) {

  if $manage {

    $server           = lookup('uio_satellite_server', String, 'first', '')
    $organization     = lookup('uio_satellite_organization', String, 'first', '')
    $virtwho_username = lookup('uio_satellite_virtwho_username', String, 'first', '')
    $virtwho_password = lookup('uio_satellite_virtwho_password', String, 'first', '')
    $proxy_hostname   = lookup('mgmt__address__proxy', String, 'first', '')
    $proxy_port       = '8888'

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
