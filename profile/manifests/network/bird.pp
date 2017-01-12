#
class profile::network::bird(
  $manage_firewall = true,
  $firewall_extras = {},
) {

  include ::bird

#  if $manage_firewall {
    # do nothing ... yet
#  }

}

