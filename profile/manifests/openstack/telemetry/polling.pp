# Ceilometer polling agent, for nodes that only poll (compute)
#
# polling.yaml and the polling interval are managed by puppet-ceilometer, via
# ceilometer::agent::polling::manage_polling and ::polling_interval in
# hieradata/common/modules/ceilometer.yaml. The namespace to poll is set per
# role, in the compute and telemetry role files.
class profile::openstack::telemetry::polling {

  include ::ceilometer
  include ::ceilometer::config
  include ::ceilometer::agent::service_credentials
  include ::ceilometer::agent::polling

}
