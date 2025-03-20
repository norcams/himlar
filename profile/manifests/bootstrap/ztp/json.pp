# Provide a sonic ztp json file
define profile::bootstrap::ztp::json(
  $ensure = present,
  $filename = $name,
  $repo_path,
  $tasks = {}
) {

  ensure_resource('file', dirname("${repo_path}/${filename}"), {'ensure' => 'directory' })

  #info("DEBUG:tasks=${tasks}")

  file { "${repo_path}/${filename}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    content => to_json_pretty({ "ztp" => $tasks })
  }

}
