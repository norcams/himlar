class profile::openstack::dashboard(
  $manage_ssl_cert = true,
  $manage_firewall = true,
  $firewall_extras = {},
) {
  include ::horizon

  if $manage_ssl_cert {
    include profile::application::sslcert
    Class['Profile::Application::Sslcert'] ~>
    Service[$::horizon::params::http_service]
  }

  if $manage_firewall {
    profile::firewall::rule { '235 openstack-dashboard accept tcp':
      port    => [80,443],
      extras  => $firewall_extras,
    }
  }
}
