define profile::application::builder::jobs(
    $image_name,
    $url,
    $latest,
    $checksum_file,
    $checksum,
    $min_ram,
    $min_disk,
    $username,
    $ensure        = present,
    $path          = 'weekly',
    $az            = $profile::application::builder::real_az,
    $user          = $profile::application::builder::user,
    $group         = $profile::application::builder::group,
    $template_dir  = $profile::application::builder::template_dir,
    $download_dir  = $profile::application::builder::download_dir,
    $rc_file       = $profile::application::builder::rc_file
) {

  file { "/etc/cron.${path}/${name}":
    ensure  => $ensure,
    content => template("${module_name}/application/builder/cronjob.erb"),
    owner   => $user,
    group   => $group
  }
}
