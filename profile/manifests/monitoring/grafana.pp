#
class profile::monitoring::grafana(
  $enable                    = false,
  $manage_firewall           = false,
  $firewall_extras           = {}
) {

  if $enable {
    include ::grafana

    $dashboard = lookup('profile::monitoring::grafana::dashboard', Hash, 'deep', {})
    create_resources('profile::monitoring::grafana::dashboard', $dashboard, { require => Class['grafana::service'] })

    if $manage_firewall {
      profile::firewall::rule { '412 grafana accept tcp':
        dport  => 8080,
        extras => $firewall_extras,
      }
    }
  }

}
