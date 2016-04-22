# Dashboard
class profile::openstack::dashboard(
  $manage_ssl_cert = false,
  $ports = [80,443,5000,6080,8773,8774,8776,9292,9696],
  $manage_firewall = true,
  $service_net = "${::network_service1}/${::netmask_service1}",
  $firewall_extras = {}
) {
  include ::horizon

  if $manage_ssl_cert {
    include profile::application::sslcert
    Class['Profile::Application::Sslcert'] ~>
    Service[$::horizon::params::http_service]
  }

  if $manage_firewall {
    $allow_from_network = hiera_array('allow_from_network')
    profile::firewall::rule { '235 public openstack-dashboard and api accept tcp':
      port   => $ports,
      source => $allow_from_network,
      extras => $firewall_extras,
    }
    profile::firewall::rule { '236 service openstack-dashboard and api accept tcp':
      port   => $ports,
      source => $service_net,
      extras => $firewall_extras,
    }
  }

}
