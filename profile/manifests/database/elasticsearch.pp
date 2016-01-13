#
# Author: Michael Chapman
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/java'
#   mod 'elasticsearch/elasticsearch'
#
class profile::database::elasticsearch::server (
  $instances = {}
) {

  include ::java
  include ::elasticsearch
  create_resources('elasticsearch::instance', $instances)
}
