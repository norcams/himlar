# Dashboard
class profile::openstack::dashboard(
  $manage_dashboard   = false,
  $manage_ssl_cert    = false,
  $ports              = [80, 443],
  $manage_firewall    = false,
  $allow_from_network = undef,
  $internal_net       = "${::network_trp1}/${::netmask_trp1}",
  $firewall_extras    = {},
  $manage_overrides   = false,
  $override_template  = "${module_name}/openstack/horizon/local_settings.erb",
  $site_branding      = 'UH-IaaS',
  $change_uploaddir   = false,
  $custom_uploaddir   = '/image-upload'
) {

  if $manage_dashboard {
    include ::horizon
    concat::fragment { 'extra-local_settings.py':
      target  => $::horizon::params::config_file,
      content => template($override_template),
      order   => '99',
    }
  }

  if $manage_ssl_cert {
    include profile::application::sslcert
    Class['Profile::Application::Sslcert'] ~>
    Service[$::horizon::params::http_service]
  }

  if $manage_firewall {
    $hiera_allow_from_network = hiera_array('allow_from_network', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }
    profile::firewall::rule { '235 public openstack-dashboard accept tcp':
      port   => $ports,
      source => $source,
      extras => $firewall_extras,
    }
  }

  if $manage_overrides {
    file { '/usr/share/openstack-dashboard/openstack_dashboard/overrides.py':
      ensure => present,
      source => "puppet:///modules/${module_name}/openstack/horizon/overrides.py",
      notify => Service['httpd']
    }
  }

  if $change_uploaddir {
    file { $custom_uploaddir:
      ensure => 'directory',
      owner  => 'apache',
    }
  }
}
