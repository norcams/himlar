#
class profile::monitoring::grafana(
  $enable                    = false,
  $manage_firewall           = false,
  $firewall_extras           = {}
) {

  if $enable {
    include ::grafana

    $dashboard = lookup('profile::monitoring::grafana::dashboard', Hash, 'deep', {})
    $datasource = lookup('profile::monitoring::grafana::datasource', Hash, 'deep', {})

    create_resources('profile::monitoring::grafana::dashboard', $dashboard, { require => Class['grafana::service'] })
    create_resources('grafana_datasource', $datasource, { require => Class['grafana::service'] })

    if $manage_firewall {
      profile::firewall::rule { '412 grafana accept tcp':
        port   => 8080,
        extras => $firewall_extras,
      }
    }
  }

}
