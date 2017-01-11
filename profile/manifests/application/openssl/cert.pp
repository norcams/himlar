#
define profile::application::openssl::cert(
    $ensure           = present,
    $crt_dir          = '/etc/pki/tls/certs',
    $key_dir          = '/etc/pki/tls/private',
    $cert_name        = $name,
    $cn               = $::fqdn,
    $altnames         = [],
    $ca_dir           = '/opt/himlar/provision/ca',
    $concat           = false,
    $concat_dhparam   = false
) {

  file { "${crt_dir}/${cert_name}.cnf":
    ensure  => $ensure,
    content => template("${module_name}/application/openssl/server.cnf.erb"),
  } ->
  ssl_pkey {  "${key_dir}/${cert_name}.key.pem":
    ensure   => $ensure,
  } ->
  x509_request { "${crt_dir}/${cert_name}.csr":
    ensure      => $ensure,
    template    => "${crt_dir}/${cert_name}.cnf",
    private_key => "${key_dir}/${cert_name}.key.pem"
  } ->
  exec { "sign ${name}":
    command => "/bin/openssl ca -config ${ca_dir}/intermediate/openssl.cnf -batch \
                -extensions v3_req -days 375 -notext -key \$(cat ${ca_dir}/passfile) \
                -md sha256 -in ${crt_dir}/${cert_name}.csr \
                -out ${crt_dir}/${cert_name}.cert.pem",
    creates => "${crt_dir}/${cert_name}.cert.pem",
  }

  if $concat {
    # Concat of dhparam will only work if profile::application::openssl::manage_dhparam = true
    if $concat_dhparam {
      $command = "cat ${key_dir}/${cert_name}.key.pem ${crt_dir}/${cert_name}.cert.pem \
        ${ca_dir}/intermediate/certs/ca-chain.cert.pem ${crt_dir}/dhparam.pem \
        > ${crt_dir}/${cert_name}.pem"
    } else {
      $command = "cat ${key_dir}/${cert_name}.key.pem ${crt_dir}/${cert_name}.cert.pem \
        ${ca_dir}/intermediate/certs/ca-chain.cert.pem > ${crt_dir}/${cert_name}.pem"
    }
    exec { "concat ${name}":
      command => $command,
      path    => '/bin',
      creates => "${crt_dir}/${cert_name}.pem",
      require => Exec["sign ${name}"]
    }
  }
}
