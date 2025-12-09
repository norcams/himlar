# This will add puppet ca to the trusted ca bundle
class profile::application::openssl::puppetca(
  $enable = false,
  $ca_path = '/etc/pki/tls/certs/'
) {

  if $enable {
    exec { 'trust puppet_localcacert':
      command => "/bin/trust anchor ${::puppet_localcacert}",
      unless => "/bin/openssl verify -CApath ${ca_path} ${::puppet_localcacert}"
    }
  }
}
