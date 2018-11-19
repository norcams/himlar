#
class profile::monitoring::grafana(
  $enable                    = false,
  $manage_firewall           = false,
  $firewall_extras           = {},
  $grafana_dashboard         = {}
) {

  if $enable {
    include ::grafana

    if $manage_firewall {
      profile::firewall::rule { '412 grafana accept tcp':
        dport  => 8080,
        extras => $firewall_extras,
      }
    }

    # dashboard
    $dashboards  = lookup('profile::monitoring::grafana::dashboards', Hash, 'deep', {})
    create_resources('profile::monitoring::grafana::dashboard', $dashboards)

  }

}
