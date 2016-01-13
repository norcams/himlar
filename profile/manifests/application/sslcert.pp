# = Class: profile::application::sslcert
#
# Author: Name Surname <name.surname@mail.com>
class profile::application::sslcert (
    $create_new     = false,
    $cert_defines   = undef,
) {

  contain ::openssl

  if $create_new {
    create_resources('openssl::certificate::x509', hiera_hash('profile::application::sslcert::cert_defines', {}))
  }
}