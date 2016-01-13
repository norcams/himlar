#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/apt'
#   mod 'puppetlabs/mongodb'
#
class profile::database::mongodb::mongos (
  $manage_mongodb_client = true,
  $shards                = {},
) {

  include ::mongodb::globals
  include ::mongodb::mongos
  create_resources('mongodb_shard', $shards)

  if $manage_mongodb_client {
    include ::mongodb::client
  }

}

