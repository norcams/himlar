#
class profile::monitoring::grafana(
  $enable                    = false,
  $datasource                = {},
  $dashboard                 = {},
  $manage_firewall           = false,
  $firewall_extras           = {}
) {

  if $enable {
    include ::grafana

    create_resources('grafana_dashboard', $dashboard, { require => Class['grafana::service'] })
    create_resources('grafana_datasource', $datasource, { require => Class['grafana::service'] })

    if $manage_firewall {
      profile::firewall::rule { '412 grafana accept tcp':
        port   => 8080,
        extras => $firewall_extras,
      }
    }
  }

}
