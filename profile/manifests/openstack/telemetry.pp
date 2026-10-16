# Ceilometer notification and central polling agents, for the telemetry role
#
# meters.d/meters.yaml and gnocchi_resources.yaml are left as the packaged
# files. Both were vendored here once and had rotted; the resource definitions
# especially need to track the ceilometer release.
class profile::openstack::telemetry {

  include ::keystone::bootstrap
  include ::ceilometer
  include ::ceilometer::config
  include ::ceilometer::logging

  # notification
  include ::ceilometer::agent::service_credentials
  include ::ceilometer::agent::notification

  # polling
  include ::ceilometer::agent::polling

  # cache
  include ::ceilometer::cache

  # gnocchi
  include ::gnocchi::client

}
