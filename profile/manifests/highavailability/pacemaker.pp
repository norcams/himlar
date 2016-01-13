class profile::highavailability::pacemaker {
} (
  include ::pacemaker
  include ::pacemaker::corosync
  include ::pacemaker::stonith
)
