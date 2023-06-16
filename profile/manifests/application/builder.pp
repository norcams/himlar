class profile::application::builder (
  $rc_file,
  $template_dir,
  $download_dir,
  $az    = undef,
  $package_url = false,
  $user  = 'imagebuilder',
  $group = 'imagebuilder',
  $flavor = 'm1.small',
  $network = 'imagebuilder',
  $insecure = false,
  $ipv6 = false,
  $custom_scriptdir = "/home/${user}/custom_scripts",
  $resolver_address = hiera('netcfg_anycast_dns', '1.1.1.1'),
  $fetch_windows_images = false,
) {


  if $az {
    $real_az = $az
  } else {
    $real_az = "${::location}-default-1"
  }

  if $package_url {
    package { 'imagebuilder':
      ensure   => installed,
      provider => 'rpm',
      source   => $package_url
    }
  }

  file { '/opt/images':
    ensure => directory,
    mode   => '0755'
  } ->
  file { '/opt/images/public_builds':
    ensure => directory,
    mode   => '0755',
    owner  => $user,
    group  => $group
  }

  file { '/etc/imagebuilder':
    ensure => directory,
    mode   => '0755'
  } ->
  file { '/etc/imagebuilder/config':
    ensure  => file,
    mode    => '0644',
    content => "[main]\ntemplate_dir = ${template_dir}/default\ndownload_dir = ${download_dir}\n"
  }

  group { $group:
    ensure => present
  } ->
  user { $user:
    ensure     => present,
    managehome => true,
    gid        => $group,
    before     => Class['profile::openstack::openrc']
  } ->
  file { "/home/${user}/build_scripts":
    ensure => directory,
    owner  => $user,
    group  => $group
  } ->
  file { $custom_scriptdir:
    ensure => directory,
    owner  => $user,
    group  => $group
  } ->
  file { '/var/log/imagebuilder':
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755'
  } ->
  # Temp. until cloud-init can handle systemd-resolved (Fedora 33 and onwards)
  file { "${custom_scriptdir}/resolver.sh":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    content => template("${module_name}/application/builder/resolver.sh.erb")
  }

  create_resources('profile::application::builder::jobs', lookup('profile::application::builder::images', Hash, 'deep', {}))
  create_resources('profile::application::builder::template', lookup('profile::application::builder::templates', Hash, 'deep', {}))

  if $fetch_windows_images {
    create_resources('profile::application::builder::windows_jobs', lookup('profile::application::builder::windows_images', Hash, 'deep', {}))
  }

  # report custom script
  $report = lookup('public__address__report', String, 'first')
  file { "${custom_scriptdir}/report.sh":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    content => template("${module_name}/application/builder/report.sh.erb")
  }

}
