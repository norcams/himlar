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
  $site_branding        = 'UH-IaaS',
  $image_visibility     = 'private',
  $change_uploaddir     = false,
  $custom_uploaddir     = '/image-upload',
  $enable_pwd_retrieval = false,
  $enable_designate     = false,
  $image_upload_mode    = undef,
  $change_region_selector = false,
  $change_login_footer  = false,
  $keystone_admin_roles = undef,
  $customize_logo       = false,
  $manage_systemd_unit  = false,
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

  if $manage_systemd_unit {

    # Include our systemd class
    include ::profile::base::systemd

    # Get the contents of the httpd systemd unit extras
    $systemd_unit_content = lookup('profile::openstack::dashboard::httpd_systemd_extras', Hash, 'deep', {})

    # Create a directory for the system unit extras
    file { '/etc/systemd/system/httpd.service.d':
      ensure => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      seltype => 'systemd_unit_file_t',
    }

    # Create the systemd unit extras file, and reload services if appropriate
    file { '/etc/systemd/system/httpd.service.d/limits.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      seltype => 'systemd_unit_file_t',
      content => template("${module_name}/base/systemd-unit.erb"),
      require => File['/etc/systemd/system/httpd.service.d'],
      notify  => [
        Exec['systemctl_daemon_reload'],
        Service['httpd'],
      ],
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

  $policy_defaults = {
    notify  => Service['httpd'],
    require => Class['horizon']
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
  }

  if $change_region_selector {
    file_line { 'clear_file_content':
      ensure            => absent,
      path              => '/usr/lib/python2.7/site-packages/horizon/templates/horizon/common/_region_selector.html',
      match             => '^.',
      match_for_absence => true,
      multiple          => true,
      replace           => false,
      require           => Class['horizon'],
      notify            => Service['httpd']
    }
  }

  if $change_login_footer {
    file { '/usr/share/openstack-dashboard/openstack_dashboard/templates/_login_footer.html':
      ensure  => present,
      source  => "puppet:///modules/${module_name}/openstack/horizon/_login_footer.html",
      require => Class['horizon'],
      notify  => Service['httpd']
    }
  }

  if $customize_logo {
    file { 'logo-splash.svg':
      ensure  => present,
      path    => '/usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/logo-splash.svg',
      source  => "puppet:///modules/${module_name}/openstack/horizon/logo-splash.svg",
      replace => true,
      require => Class['horizon'],
      notify  => Service['httpd']
    }
    file { 'logo.svg':
      ensure  => present,
      path    => '/usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/logo.svg',
      source  => "puppet:///modules/${module_name}/openstack/horizon/logo.svg",
      replace => true,
      require => Class['horizon'],
      notify  => Service['httpd']
    }
    file { 'favicon.ico':
      ensure  => present,
      path    => '/usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/favicon.ico',
      source  => "puppet:///modules/${module_name}/openstack/horizon/favicon.ico",
      replace => true,
      require => Class['horizon'],
      notify  => Service['httpd']
    }
  }
}
