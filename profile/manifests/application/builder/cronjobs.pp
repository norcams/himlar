define profile::application::builder::cronjobs(
    $ensure        = present,
    $period        = 'weekly',
    $az            = $profile::application::builder::az,
    $image_name,
    $url,
    $latest,
    $checksum_file,
    $checksum,
    $min_ram,
    $min_disk,
    $username
) {

  file { "/etc/cron.${period}/${name}":
    ensure  => $ensure,
    content => template("${module_name}/application/builder/cronjob.erb"),
  }
}
