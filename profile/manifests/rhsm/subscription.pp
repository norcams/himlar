class profile::rhsm::subscription (
  $manage              = false,
  $server              = undef,
  $organization        = undef,
  $activationkey       = undef,
  $rhsm_proxy_hostname = '172.28.32.12',
  $rhsm_proxy_port     = '8888'
) {

  if $manage {
    include ::subscription_manager

    class { 'subscription_manager':
      server_hostname => $server,
      org             => $organization,
      activationkey   => $activationkey,
      autosubscribe   => false,
      config_hash     => {
        server_prefix           => '/rhsm',
        rhsm_baseurl            => "https://${server}/pulp/repos",
        rhsm_repo_ca_cert       => '%(ca_cert_dir)s/katello-server-ca.pem',
        auto_enable_yum_plugins => false,
        proxy_hostname          => $rhsm_proxy_hostname,
        proxy_port              => $rhsm_proxy_port,
      },
      service_name    => 'rhsmcertd',
      force           => false,
    }
  }
}
