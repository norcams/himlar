#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'maestrodev/wget'
#   mod' puppetlabs/gcc'
#
class profile::database::redis (
  $manage_sentinel = false,
) {

  include ::redis

  if $manage_sentinel {
    include ::redis::sentinel
  }
}
