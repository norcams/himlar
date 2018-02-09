#
class profile::application::openssl(
  $ssl_path         = '/etc/pki/tls',
  $ca_dir           = '/opt/himlar/provision/ca',
  $manage_ca_cert   = false,
  $manage_dhparam   = false
) {

  include ::openssl

  $certs = lookup('profile::application::openssl::certs', Hash, 'deep', {})
  create_resources('profile::application::openssl::cert', $certs,
    { require => Exec['generate /tmp/serial']})

  exec { 'generate /tmp/serial':
    command => '/bin/date +%s > /tmp/serial',
    creates => '/tmp/serial'
  }

  if $manage_ca_cert {
    exec { "${ssl_path}/certs/cachain.pem":
      command => "/bin/cp ${ca_dir}/intermediate/certs/ca-chain.cert.pem ${ssl_path}/certs/cachain.pem",
      creates => "${ssl_path}/certs/cachain.pem"
    }
  }

  if $manage_dhparam {
    dhparam { "${ssl_path}/certs/dhparam.pem":
      ensure => present,
      size   => 2048,
    }
  }

}
