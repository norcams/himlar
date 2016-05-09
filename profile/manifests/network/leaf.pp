#
#
class profile::network::leaf(
  $manage_license     = false,
  $cumulus_license    = "user@example.com|00000000000000000000000000000000000000000000000000\n",
) {
  include quagga

  if $manage_license {
    file { '/tmp/licfile':
      ensure  => file,
      content => $cumulus_license,
    }
  }
}
