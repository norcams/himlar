# Dashboard
class profile::openstack::dashboard(
  $manage_dashboard     = false,
  $ports                = [80, 443],
  $manage_firewall      = false,
  $internal_net         = "${::network_trp1}/${::netmask_trp1}",
  $firewall_extras      = {},
  $manage_overrides     = false,
  $database             = {},
  $override_template    = "${module_name}/openstack/horizon/local_settings.erb",
  $site_branding        = 'UH-IaaS',
  $change_uploaddir     = false,
  $custom_uploaddir     = '/image-upload',
  $enable_pwd_retrieval = false,
  $enable_designate     = false,
  $image_upload_mode    = undef,
  $change_region_selector = false,
  $change_login_footer  = false,
  ) {

  if $manage_dashboard {
    include ::horizon
    concat::fragment { 'extra-local_settings.py':
      target  => $::horizon::params::config_file,
      content => template($override_template),
      order   => '99',
      notify  => Service['httpd']
    }
  }

  if $database {
    # Run syncdb if we use database backend
    exec { 'horizon syncdb':
      command => '/usr/share/openstack-dashboard/manage.py syncdb --noinput && touch /usr/share/openstack-dashboard/.syncdb',
      user    => 'root',
      creates => '/usr/share/openstack-dashboard/.syncdb',
      require => [Concat::Fragment['extra-local_settings.py'], Package['horizon']]
    }
  }

  $policies = lookup('profile::openstack::dashboard::policies', Hash, 'deep', {})
  create_resources('openstacklib::policy::base', $policies, { require => Class['horizon']})

  if $manage_firewall {
    profile::firewall::rule { '235 public openstack-dashboard accept tcp':
      dport  => $ports,
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

  # Designate plugin
  if $enable_designate {
    file { '/usr/share/openstack-dashboard/openstack_dashboard/local/enabled/_1710_project_dns_panel_group.py':
      ensure => present,
      source => 'file:///usr/lib/python2.7/site-packages/designatedashboard/enabled/_1710_project_dns_panel_group.py',
      notify => Service['httpd']
    }
    file { '/usr/share/openstack-dashboard/openstack_dashboard/local/enabled/_1721_dns_zones_panel.py':
      ensure => present,
      source => 'file:///usr/lib/python2.7/site-packages/designatedashboard/enabled/_1721_dns_zones_panel.py',
      notify => Service['httpd']
    }
#    file { '/usr/share/openstack-dashboard/openstack_dashboard/local/enabled/_1722_dns_reversedns_panel.py':
#      ensure => present,
#      source => 'file:///usr/lib/python2.7/site-packages/designatedashboard/enabled/_1722_dns_reversedns_panel.py',
#      notify => Service['httpd']
#    }
  }

  if $change_region_selector {
    file_line { 'clear_file_content':
      ensure            => absent,
      path              => '/usr/lib/python2.7/site-packages/horizon/templates/horizon/common/_region_selector.html',
      match             => '^.',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
    }
  }

  if $change_login_footer {
    file { '/usr/share/openstack-dashboard/openstack_dashboard/templates/_login_footer.html':
      ensure => present,
      source => "puppet:///modules/${module_name}/openstack/horizon/_login_footer.html",
    }
  }
}
