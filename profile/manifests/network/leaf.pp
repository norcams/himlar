#
#
class profile::network::leaf(
  $manage_license     = false,
  $cumulus_license    = "user@example.com|00000000000000000000000000000000000000000000000000\n",
  $manage_quagga      = false,
  $manage_acls        = false,
) {

  if $manage_acls {
    create_resources(profile::network::leaf::acl, lookup('profile::network::leaf::acls', Hash, 'deep', {}))
  }

  if $manage_license {
    file { '/etc/cumulus/.license':
      ensure  => file,
      content => $cumulus_license,
    }
  }

  if $manage_quagga {
    include quagga
  }
}
