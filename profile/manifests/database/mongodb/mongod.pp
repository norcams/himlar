#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/apt'
#   mod 'puppetlabs/mongodb'
#
class profile::database::mongodb::mongod (
  $manage_mongodb_client = true,
  $replsets              = {},
  $users                 = {},
  $databases             = {},
) {

  include ::mongodb::globals
  include ::mongodb::server
  create_resources('mongodb_replset', $replsets)
  create_resources('mongodb_user', $users)
  create_resources('mongodb_database', $databases)

  if $manage_mongodb_client {
    include ::mongodb::client
  }

}

