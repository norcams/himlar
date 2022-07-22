# Class: profile::monitoring::influxdb::auth
#
# Create a new auth token
#

define profile::monitoring::influxdb::auth(
  Boolean $ensure = present,
  String $token,
  String $org,
  Hash $permissions
) {

  file { "/var/lib/grafana/dashboards/${name}.json":
    ensure  => file,
    content => template("${module_name}/monitoring/grafana/dashboard/${template}.json.erb"),
  }

}
