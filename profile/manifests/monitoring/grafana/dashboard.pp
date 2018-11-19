# Wrapper for grafana dashboard to allow templates
define profile::monitoring::grafana::dashboard(
  $template = $name
) {

  file { "/var/lib/grafana/dashboards/${name}.json":
    ensure  => file,
    content => template("${module_name}/monitoring/grafana/dashboard/${template}.json.erb"),
  }

}
