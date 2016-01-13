#
# Author: Michael Chapman
# License: ApacheV2
#
class profile::logging::kibana::server (
) {

  include ::kibana3
  include ::apache
}
