#
# = Class: profile::application::sslcert
#
class profile::application::sslcert (
    $ensure = present,
    $crt_dir = '/etc/pki/tls/certs',
    $key_dir = '/etc/pki/tls/private',
    $cert_name = $::fqdn,
    $commonname = $::fqdn,
    $organization = 'private.org',
    $email = 'user@example.com',
    $altnames = [],
    $ca_dir = '/opt/himlar/provision/ca',
    $serial = fqdn_rand_string(10, '0123456789ABCDEF')
) {

  contain ::openssl

  file { "${crt_dir}/${cert_name}.cnf":
    ensure  => $ensure,
    content => template("${module_name}/application/openssl/server.cnf.erb"),
  } ->
  ssl_pkey {  "${key_dir}/${cert_name}.key":
    ensure   => $ensure,
  } ->
  x509_request { "${crt_dir}/${cert_name}.csr":
    ensure      => $ensure,
    template    => "${crt_dir}/${cert_name}.cnf",
    private_key => "${key_dir}/${cert_name}.key"
  } ->
  exec { 'generate tmp serial':
    command => '/bin/date +%s > /tmp/serial',
    creates => '/tmp/serial'
  } ->
  exec { 'sign-sslcert':
    command => "/bin/openssl ca -config ${ca_dir}/root.cnf -batch \
                -extensions server_cert -days 375 -create_serial -notext \
                -sha256 -in ${crt_dir}/${cert_name}.csr \
                -out ${crt_dir}/${cert_name}.crt",
    creates => "${crt_dir}/${cert_name}.crt",
  }

  info("/bin/openssl ca -config ${ca_dir}/root.cnf -batch \
                -extensions server_cert -days 375 -create_serial -notext \
                -sha256 -in ${crt_dir}/${cert_name}.csr \
                -out ${crt_dir}/${cert_name}.crt")
}
