#
#
class profile::network::leaf(
  $manage_license     = false,
  $cumulus_license    = "user@example.com|00000000000000000000000000000000000000000000000000\n",
  $manage_quagga      = false,
  $manage_acls        = false,
  $acls               = {},
) {

  if $manage_acls {
    create_resources(profile::network::leaf::acl, hiera_hash('profile::network::leaf::acls', {}))
  }

  if $manage_license {
    file { '/tmp/licfile':
      ensure  => file,
      content => $cumulus_license,
    } ->
    cumulus_license { 'cumulus_license':
      src => '/tmp/licfile',
#      Ideally restart switchd, but the service is not defined in our code.
#      notify => Service['switchd']
    }
  }

  if $manage_quagga {
    include quagga
  }

  if $manage_acls {

  }
}
