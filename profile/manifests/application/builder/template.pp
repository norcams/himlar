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
  # HCL2. imagebuilder looks for template.pkr.hcl first, and only an HCL2
  # template can declare required_plugins, which is what lets it run
  # 'packer init' to install the openstack builder. Packer stopped bundling
  # builder plugins in 1.10.
  file { "${template_dir}/${name}/template.pkr.hcl":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/application/builder/template.pkr.hcl.erb"),
  } ->
  # The legacy JSON template stays in place so that rolling the imagebuilder
  # package back keeps working. imagebuilder prefers template.pkr.hcl when both
  # are present, so this is inert for a current build. Remove once the rollback
  # window has passed.
  file { "${template_dir}/${name}/template":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/application/builder/template.erb"),
  }

}
