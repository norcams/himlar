# Dashboard
class profile::openstack::dashboard(
  $manage_dashboard     = false,
  $ports                = [80, 443],
  $manage_firewall      = false,
  $allow_from_network   = undef,
  $internal_net         = "${::network_trp1}/${::netmask_trp1}",
  $firewall_extras      = {},
  $manage_overrides     = false,
  $override_template    = "${module_name}/openstack/horizon/local_settings.erb",
  $site_branding        = 'UH-IaaS',
  $change_uploaddir     = false,
  $custom_uploaddir     = '/image-upload',
  $enable_pwd_retrieval = false,
  $image_upload_mode    = undef,
  $change_region_selector = false
) {

  if $manage_dashboard {
    include ::horizon
    concat::fragment { 'extra-local_settings.py':
      target  => $::horizon::params::config_file,
      content => template($override_template),
      order   => '99',
    }
  }

  $policies = lookup('profile::openstack::dashboard::policies', Hash, 'deep', {})
  create_resources('openstacklib::policy::base', $policies, { require => Class['horizon']})

  if $manage_firewall {
    $hiera_allow_from_network = lookup('allow_from_network', Array, 'unique', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }
    profile::firewall::rule { '235 public openstack-dashboard accept tcp':
      dport  => $ports,
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

  if $change_region_selector {
    file_line { 'clear_ file_content':
      ensure            => absent,
      path              => '/usr/lib/python2.7/site-packages/horizon/templates/horizon/common/_region_selector.html',
      match             => '^.',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
    }
  }
}
