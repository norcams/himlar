class profile::openstack::dashboard(
  $manage_ssl_cert = true,
  $manage_firewall = true,
  $firewall_extras = {},
  $vhost_definition = {}
) {
  include ::horizon

  if $manage_ssl_cert {
    include profile::application::sslcert
    Class['Profile::Application::Sslcert'] ~>
    Service[$::horizon::params::http_service]
  }

  if $manage_firewall {
    $allow_from_network = hiera_array('allow_from_network')
    profile::firewall::rule { '235 openstack-dashboard and api accept tcp':
      port    => [80,443,5000,8773,8774,8776,9292,9696],
      source  => $allow_from_network,
      extras  => $firewall_extras,
    }
  }

  # Used for API proxy
  create_resources('::apache::vhost', $vhost_definition)

}
