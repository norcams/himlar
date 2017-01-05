# rsyslog client for Openstack
class profile::logging::rsyslog::client(
  $manage_rsyslog = false,
) {

  if $manage_rsyslog {
    include ::rsyslog::client
  }

}
