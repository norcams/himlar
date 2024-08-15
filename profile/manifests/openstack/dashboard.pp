# Dashboard
class profile::openstack::dashboard(
  $manage_dashboard     = false,
  $ports                = [80, 443],
  $manage_firewall      = false,
  $allow_from_network   = undef,
  $internal_net         = "${::network_trp1}/${::netmask_trp1}",
  $firewall_extras      = {},
  $manage_overrides     = false,
  $database             = {},
  $override_template    = "${module_name}/openstack/horizon/local_settings.erb",
  $site_branding        = 'NREC',
  $image_visibility     = 'private',
  $change_uploaddir     = false,
  $custom_uploaddir     = '/image-upload',
  $enable_pwd_retrieval = false,
  $enable_designate     = false,
  $disable_admin_dashboard = false,
  $change_region_selector = false,
  $change_login_footer  = false,
  $keystone_admin_roles = undef,
  $customize_logo       = false,
  $user_menu_links      = undef,
  $session_cookie_httponly = false,
  $access_control_allow_origin = false,
  $use_ssl = false,
  $cutomize_charts_dashboard_overview = false,
  $disallow_iframe_embed   = false,
  $csrf_cookie_secure      = false,
  $session_cookie_secure   = false,
  $disable_password_reveal = false,
  $enforce_password_check  = false,
  $secure_proxy_header     = false,
  $password_autocomplete   = undef,
  $launch_instance_defaults = {},
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
    exec { 'horizon migrate':
      command => '/usr/share/openstack-dashboard/manage.py migrate --noinput && touch /usr/share/openstack-dashboard/.migrate',
      user    => 'root',
      creates => '/usr/share/openstack-dashboard/.migrate',
      require => [Concat::Fragment['extra-local_settings.py'], Package['horizon']]
    }
  }

  $policy_defaults = {
    notify  => Service['httpd'],
    require => Class['horizon'],
    file_mode =>  '0644'
  }
  $policies = lookup('profile::openstack::dashboard::policies', Hash, 'deep', {})
  create_resources('openstacklib::policy::base', $policies, $policy_defaults)

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
      ensure  => present,
      source  => "puppet:///modules/${module_name}/openstack/horizon/overrides.py",
      notify  => Service['httpd'],
      require => Class['horizon']
    }
  }

  if $change_uploaddir {
    file { $custom_uploaddir:
      ensure => 'directory',
      owner  => 'apache',
    }
  }

  # Designate: Install the Designate plugin (RPM packages) for Horizon
  # if "enable_designate" is set to true
  if $enable_designate {
    $designate_packages = lookup('profile::openstack::dashboard::designate_packages', Hash, 'deep', {})
    create_resources('profile::base::package', $designate_packages)

    # FIXME: Temporary workaround for el8 designate-ui rpm setting wrong permissions
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '8' {
      $designate_ui_path = '/usr/share/openstack-dashboard/openstack_dashboard/local/enabled/'
      file { '_1710_project_dns_panel_group.py':
        path   => "${designate_ui_path}_1710_project_dns_panel_group.py",
        mode   => '0644',
        notify => Service['httpd'],
      }
      file { '_1721_dns_zones_panel.py':
        path   => "${designate_ui_path}_1721_dns_zones_panel.py",
        mode   => '0644',
        notify => Service['httpd'],
      }
      file { '_1722_dns_reversedns_panel.py':
        path   => "${designate_ui_path}_1722_dns_reversedns_panel.py",
        mode   => '0644',
        notify => Service['httpd'],
      }
      file { '_1710_project_dns_panel_group.cpython-36.pyc':
        path   => "${designate_ui_path}__pycache__/_1710_project_dns_panel_group.cpython-36.pyc",
        mode   => '0644',
        notify => Service['httpd'],
      }
      file { '_1721_dns_zones_panel.cpython-36.pyc':
        path   => "${designate_ui_path}__pycache__/_1721_dns_zones_panel.cpython-36.pyc",
        mode   => '0644',
        notify => Service['httpd'],
      }
      file { '_1722_dns_reversedns_panel.cpython-36.pyc':
        path   => "${designate_ui_path}__pycache__/_1722_dns_reversedns_panel.cpython-36.pyc",
        mode   => '0644',
        notify => Service['httpd'],
      }
    }
  }

  # Disable the admin dashboard if "disable_admin" is set to true
  if $disable_admin_dashboard {
    file { '/usr/share/openstack-dashboard/openstack_dashboard/local/enabled/_40_disable-admin-dashboard.py':
      ensure  => present,
      mode    => '0644',
      source  => "puppet:///modules/${module_name}/openstack/horizon/_40_disable-admin-dashboard.py",
      require => Class['horizon'],
      notify  => Service['httpd']
    }
  }

  if $change_region_selector {
    case $::operatingsystemmajrelease {
      '7': {
        $python_version = '2.7'
      }
      '8': {
        $python_version = '3.6'
      }
      default: {
      }
    }
    file_line { 'clear_file_content':
      ensure            => absent,
      path              => "/usr/lib/python${python_version}/site-packages/horizon/templates/horizon/common/_region_selector.html",
      match             => '^.',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
      notify            => Service['httpd']
    }
  }

  if $change_login_footer {
    file { '/usr/share/openstack-dashboard/openstack_dashboard/templates/_login_form_footer.html':
      ensure  => present,
      source  => "puppet:///modules/${module_name}/openstack/horizon/_login_form_footer.html",
      require => Class['horizon'],
      notify  => Service['httpd']
    }
  }

  if $customize_logo {
    file { 'logo-splash.svg':
      ensure  => present,
      path    => '/usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/logo-splash.svg',
      source  => "puppet:///modules/${module_name}/openstack/horizon/img/logo-splash.svg",
      replace => true,
      require => Class['horizon'],
    } ->
    file { 'logo.svg':
      ensure  => present,
      path    => '/usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/logo.svg',
      source  => "puppet:///modules/${module_name}/openstack/horizon/img/logo.svg",
      replace => true,
      require => Class['horizon'],
    } ->
    file { 'favicon.ico':
      ensure  => present,
      path    => '/usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/favicon.ico',
      source  => "puppet:///modules/${module_name}/openstack/horizon/img/favicon.ico",
      replace => true,
      require => Class['horizon'],
      notify  => Service['httpd']
    }
  }

  if $cutomize_charts_dashboard_overview {
    file_line { 'remove_floatingip_chart':
      ensure            => absent,
      path              => '/usr/share/openstack-dashboard/openstack_dashboard/usage/views.py',
      match             => '^.*floatingip.*?\),',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
    } ->
    file_line { 'remove_floatingip_l2':
      ensure            => absent,
      path              => '/usr/share/openstack-dashboard/openstack_dashboard/usage/views.py',
      match             => '^.*pgettext_lazy.*?\),',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
    } ->
    file_line { 'remove_floatingip_l3':
      ensure            => absent,
      path              => '/usr/share/openstack-dashboard/openstack_dashboard/usage/views.py',
      match             => '^.\s+None\),',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
    } ->
    file_line { 'remove_network_chart':
      ensure            => absent,
      path              => '/usr/share/openstack-dashboard/openstack_dashboard/usage/views.py',
      match             => '^.*network.*?\)*None\),',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
    } ->
    file_line { 'remove_port_chart':
      ensure            => absent,
      path              => '/usr/share/openstack-dashboard/openstack_dashboard/usage/views.py',
      match             => '^.*port.*?\)*None\),',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
    } ->
    file_line { 'remove_route_chart':
      ensure            => absent,
      path              => '/usr/share/openstack-dashboard/openstack_dashboard/usage/views.py',
      match             => '^.*router.*?\)*None\),',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
      notify            => Service['httpd']
    }
  }
}
