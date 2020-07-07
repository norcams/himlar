class profile::rhsm::virtwho (
  $manage                  = false,
  $owner                   = undef,
  $rhsm_hostname           = undef,
  $rhsm_username           = undef,
  $rhsm_encrypted_password = undef,
  $rhsm_proxy_hostname     = '172.28.32.12',
  $rhsm_proxy_port         = '8888'
) {

  if $manage {

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
