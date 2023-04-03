define profile::application::builder::template(
    $ensure           = present,
    $template_dir     = $profile::application::builder::template_dir,
    $insecure         = $profile::application::builder::insecure,
    $ipv6             = $profile::application::builder::ipv6,
    $custom_scriptdir = $profile::application::builder::custom_scriptdir,
    $custom_scripts   = [],
) {

  file { "${template_dir}/${name}":
    ensure => directory,
    mode   => '0755'
  } ->
  file { "${template_dir}/${name}/template":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/application/builder/template.erb"),
  }

}
