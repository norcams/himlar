define profile::application::builder::cronjobs(
    $image_name,
    $url,
    $latest,
    $checksum_file,
    $checksum,
    $min_ram,
    $min_disk,
    $username,
    $ensure        = present,
    $period        = 'weekly',
    $az            = $profile::application::builder::az
) {

  file { "/etc/cron.${period}/${name}":
    ensure  => $ensure,
    content => template("${module_name}/application/builder/cronjob.erb"),
  }
}
