#
define profile::application::builder::windows_jobs (
    $version,
    $buildhost,
    $ensure        = present,
    $user          = $profile::application::builder::user,
    $group         = $profile::application::builder::group,
    $environment   = [ 'PLACEHOLDER=true' ],
    $weekday       = 3,
    $monthday      = '8-14',
    $hour          = fqdn_rand(23, $name),
    $minute        = 0
) {

  file { "/home/${user}/build_scripts/${name}_wrapper":
    ensure  => $ensure,
    content => template("${module_name}/application/builder/windows_build_script_wrapper.erb"),
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => File["/home/${user}/build_scripts"]
  } ->
  file { "/home/${user}/build_scripts/${name}":
    ensure  => $ensure,
    content => template("${module_name}/application/builder/windows_build_script.erb"),
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => File["/home/${user}/build_scripts"]
  } ->
  cron { $name:
    ensure      => $ensure,
    # Do not run unless it is Wednesday, and Write to imagebuilder report
    command     => "test $(date +\%u) -eq 3 && /home/${user}/build_scripts/${name}_wrapper || jq -nc '{\"result\": \"failed\"}' > /var/log/imagebuilder/${name}-report.jsonl",
    user        => $user,
    weekday     => $weekday,
    monthday    => $monthday,
    hour        => $hour,
    minute      => $minute,
    environment => $environment
  }
}
