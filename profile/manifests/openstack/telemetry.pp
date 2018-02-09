class profile::openstack::telemetry (
  $manage_firewall   = false,
  $firewall_extras   = {},
)  {
  include ::ceilometer
  include ::nova

  # wrappe (mange av) disse i boolske variabler(?)
  include ::profile::openstack::telemetry::centralagent
  include ::profile::openstack::telemetry::collector
  include ::profile::openstack::telemetry::notification
#  include ::profile::openstack::telemetry::api

#  include ::ceilometer::db
#  include ::ceilometer::expirer
  include ::ceilometer::client
  include ::ceilometer::agent::auth
  include ::ceilometer::agent::polling
  include ::ceilometer::keystone::auth
  include ::ceilometer::keystone::authtoken
  include ::ceilometer::dispatcher::gnocchi
  include ::gnocchi::client


  if $manage_firewall {
    profile::firewall::rule { '8777 ceilometer accept tcp':
      port        => 8777,
      proto       => 'tcp',
      destination => $::ipaddress_trp1,
      extras      => $firewall_extras,
    }
  }
}
