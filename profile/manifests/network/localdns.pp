# Use /etc/hosts for a simple local DNS
class profile::network::localdns(

) {

  $hosts = hiera_hash('profile::network::localdns::hosts', {})
  create_resources('host', $hosts, { provider => 'augeas'} )

}
