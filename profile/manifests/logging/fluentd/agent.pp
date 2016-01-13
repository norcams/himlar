#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   * srf/fluentd
#
class profile::logging::fluentd::agent (
  $sources = {},
  $matches = {},
  $plugins = {},
) {
  include ::fluentd

  ensure_resource('fluentd::configfile', keys($sources))
  ensure_resource('fluentd::configfile', keys($matches))
  create_resources('fluentd::source', $sources)
  create_resources('fluentd::match', $matches)
  create_resources('fluentd::install_plugin', $plugins)

}
