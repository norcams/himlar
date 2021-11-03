#
class profile::monitoring::prometheus(
  $server                    = false,
  $node_exporter             = false,
) {

  include ::prometheus

  if $server {
    include profile::monitoring::prometheus::server
  }
}
