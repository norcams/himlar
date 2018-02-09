class profile::application::builder (
  $rc_file,
  $template_dir,
  $download_dir,
  $az    = undef,
  $package = 'imagebuilder',
  $user  = 'imagebuilder',
  $group = 'imagebuilder',
  $flavor = 'm1.small',
  $network = 'imagebuilder',
  $insecure = false,
  $ipv6 = false
) {

  if $az {
    $real_az = $az
  } else {
    $real_az = "${::location}-default-1"
  }

  package { $package:
    ensure => installed
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
    content => "[main]\ntemplate_dir = ${template_dir}\ndownload_dir = ${download_dir}\n"
  } ->
  file { "${template_dir}/template":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/application/builder/template.erb"),
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
  }

  create_resources('profile::application::builder::jobs', lookup('profile::application::builder::images', Hash, 'deep', {}))
}
