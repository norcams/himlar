# This class will add a cert to centos ca-trust. DO NOT USE IN PROD!
class profile::application::openssl::catrust(
  $ca_cert,
) {

  if $ca_cert =~ /(.*\/)(.*\.pem)/ {
    $base_path = $1
    $filename = $2
  } else {
    err("${ca_cert} not a valid pem file path")
  }

  #copy ca-cert
  exec { 'copy-ca-cert-to-trust':
    command => "cp ${ca_cert} /etc/pki/ca-trust/source/anchors/${filename}",
    path    => '/bin:/usr/bin',
    creates => "/etc/pki/ca-trust/source/anchors/${filename}",
    notify  => Exec['update-ca-trust']
  }

  # update ca trust
  exec { 'update-ca-trust':
    command     => '/bin/update-ca-trust',
    refreshonly => true
  }

}
