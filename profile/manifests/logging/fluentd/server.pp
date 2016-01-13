#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   * srf/fluentd
#   * elasticsearch/elasticsearch
#
class profile::logging::fluentd::server (
) {

  include profile::logging::agent::fluentd
  include ::java
  include ::elasticsearch
  include ::kibana3
  include ::apache
  elasticsearch::instance { 'fluentd' : }

}
