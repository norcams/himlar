define profile::application::builder::jobs(
    $image_name,
    $url,
    $latest,
    $min_ram,
    $min_disk,
    $username,
    $checksum_file = "",
    $checksum      = "",
    $efi           = false,
    $ensure        = present,
    $flavor        = $profile::application::builder::flavor,
    $network       = $profile::application::builder::network,
    $az            = $profile::application::builder::real_az,
    $user          = $profile::application::builder::user,
    $group         = $profile::application::builder::group,
    $template_dir  = $profile::application::builder::template_dir,
    $download_dir  = $profile::application::builder::download_dir,
    $rc_file       = $profile::application::builder::rc_file
) {

  file { "/home/${user}/build_scripts/${name}":
    ensure  => $ensure,
    content => template("${module_name}/application/builder/build_script.erb"),
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => File["/home/${user}/build_scripts"]
  }

}
