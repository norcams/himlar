#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'yguenane/jpackage'
#   mod 'puppetlabs/java'
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/concat'
#   mod 'nanliu/staging'
#   mod 'puppetlabs/tomcat'
#
class profile::webserver::tomcat (
  $install_jpackage  = false,
  $instances         = {},
  $services          = {},
  $wars              = {},
  $entries_config    = {},
  $servers_config    = {},
  $connectors_config = {},
  $engines_config    = {},
  $hosts_config      = {},
  $services_config   = {},
  $valves_config     = {},
) {

  Tomcat::Instance <| |> -> Tomcat::Service <| |> -> Tomcat::War <| |>

  Tomcat::Setenv::Entry <| |> ~> Tomcat::Service <| |>
  Tomcat::Config::Server::Connector <| |> ~> Tomcat::Service <| |>
  Tomcat::Config::Server::Engine <| |> ~> Tomcat::Service <| |>
  Tomcat::Config::Server::Host <| |> ~> Tomcat::Service <| |>
  Tomcat::Config::Server::Service <| |> ~> Tomcat::Service <| |>
  Tomcat::Config::Server::Valve <| |> ~> Tomcat::Service <| |>

  if $install_jpackage {
    include ::jpackage
  }

  include ::java
  include ::tomcat

  create_resources('tomcat::instance', $instances)
  create_resources('tomcat::service', $services)
  create_resources('tomcat::war', $wars)
  create_resources('tomcat::setenv::entry', $entries_config)
  create_resources('tomcat::config::server', $servers_config)
  create_resources('tomcat::config::server::connector', $connectors_config)
  create_resources('tomcat::config::server::engine', $engines_config)
  create_resources('tomcat::config::server::host', $hosts_config)
  create_resources('tomcat::config::server::service', $services_config)
  create_resources('tomcat::config::server::valve', $valves_config)
  
}
