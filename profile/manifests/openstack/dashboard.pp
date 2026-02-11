# Dashboard
class profile::openstack::dashboard(
  $manage_dashboard     = false,
  $ports                = [80, 443],
  $manage_firewall      = false,
  $manage_firewall6     = false,
  $allow_from_network   = undef,
  $allow_from_network6  = undef,
  $internal_net         = "${::network_trp1}/${::netmask_trp1}",
  $firewall_extras      = {},
  $manage_overrides     = false,
  $manage_logos         = false,
  $database             = {},
  $override_template    = "${module_name}/openstack/horizon/local_settings.erb",
  $enable_designate     = false,
  $disable_admin_dashboard = false,
  $change_region_selector = false,
  $change_login_footer  = false,
  $keystone_admin_roles = undef,
  $customize_logo       = false,
  $maintenance_page     = false,
  $user_menu_links      = undef,
  $access_control_allow_origin = false,
  $cutomize_charts_dashboard_overview = false,
  $launch_instance_defaults = {},
  $simultaneous_sessions = 'disconnect',
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

  # Designate: Load designate class if "enable_designate" is set to true
  if $enable_designate {
    include ::horizon::dashboards::designate
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
    #notify  => Service['httpd'],
    require => Class['horizon'],
    file_mode =>  '0644',
    file_format => 'yaml'
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

  if $manage_firewall6 {
    $hiera_allow_from_network6 = lookup('allow_from_network6', Array, 'unique', [])
    $source6 = $allow_from_network6? {
      undef   => $hiera_allow_from_network6,
      ''      => $hiera_allow_from_network6,
      default => $allow_from_network6,
    }
    profile::firewall::rule { '235 public openstack-dashboard accept tcp6':
      dport  => $ports,
      source => $source6,
      extras => $firewall_extras,
      provider => 'ip6tables',
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
      '9': {
        $python_version = '3.9'
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

  if $manage_logos {
    file { '/var/www/html/logos':
      ensure => 'directory',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    } ->
    file { 'uio_emb.png':
      ensure  => present,
      path    => '/var/www/html/logos/uio_emb.png',
      source  => "puppet:///modules/${module_name}/openstack/horizon/img/uio_emb.png",
      replace => true,
      require => Class['horizon'],
    } ->
    file { 'uib_emb.png':
      ensure  => present,
      path    => '/var/www/html/logos/uib_emb.png',
      source  => "puppet:///modules/${module_name}/openstack/horizon/img/uib_emb.png",
      replace => true,
      require => Class['horizon'],
    } ->
    file { 'logo_neic.png':
      ensure  => present,
      path    => '/var/www/html/logos/logo_neic.png',
      source  => "puppet:///modules/${module_name}/openstack/horizon/img/logo_neic.png",
      replace => true,
      require => Class['horizon'],
    } ->
    file { 'logo_naic.svg':
      ensure  => present,
      path    => '/var/www/html/logos/logo_naic.svg',
      source  => "puppet:///modules/${module_name}/openstack/horizon/img/logo_naic.svg",
      replace => true,
      require => Class['horizon'],
    } ->
    file { 'nrec-logos.conf':
      ensure  => present,
      path    => '/etc/httpd/conf.d/nrec-logos.conf',
      source  => "puppet:///modules/${module_name}/openstack/horizon/httpd.conf.d/nrec-logos.conf",
      replace => true,
      require => Class['horizon'],
      notify  => Service['httpd']
    }
  }

  # To use this:
  # - enable this block with $maintenance_page = true (this can be done permanently)
  # - touch /var/www/maintenance to show page
  # - rm /var/www/maintenance to remove the page
  if $maintenance_page {
    file { 'horizon_maintenance.html':
      ensure  => present,
      path    => '/var/www/maintenance.html',
      source  => "puppet:///modules/${module_name}/openstack/horizon/maintenance.html",
      require => Class['horizon'],
      notify  => Service['httpd']
    }

    file { 'horizon_maintenance.conf':
      ensure  => present,
      path    => '/etc/httpd/vhosts.d/maintenance.conf',
      source  => "puppet:///modules/${module_name}/openstack/horizon/vhosts.d/maintenance.conf",
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
