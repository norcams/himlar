# Wrapper for grafana dashboard to allow templates
define profile::monitoring::grafana::dashboard(
  $grafana_url,
  $grafana_user,
  $grafana_password,
  $content,
) {

  grafana_dashboard { $name:
    grafana_url      => $grafana_url,
    grafana_user     => $grafana_user,
    grafana_password => $grafana_password,
    content          => template("${module_name}/monitoring/grafana/dashboard/${content}"),
  }

}
