class profile::openstack::telemetry::api {
  include profile::openstack::telemetry

  include ::ceilometer::db
  include ::ceilometer::api
  include ::ceilometer::expirer

}
