class profile::openstack::mistral (
  $manage_firewall = false
)
{
  include ::mistral
  include ::mistral::db
  include ::mistral::api
  include ::mistral::engine
  include ::mistral::event_engine
  include ::mistral::executor

  if $manage_firewall {
    profile::firewall::rule { '001 mistral incoming':
      port   => 8989,
      proto  => 'tcp'
    }
  }
}
