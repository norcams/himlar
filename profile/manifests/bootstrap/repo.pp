# This setup the files needed in /opt/repo/public for ztp
class profile::bootstrap::repo(
  $manage_repo = false,
  $repo_path = '/opt/repo/public',
  $repo_address = undef,
  $provision_files = [],
  $ztp_json = {}
) {

  if $manage_repo {
    # Vars

    # repo address for web server
    unless $repo_address {
      $repo_address_real = lookup('mgmt__address__repo', String, 'deep')
    } else {
      $repo_address_real = $repo_address
    }

    # files
    file { $repo_path:
      ensure => directory
    }

    # custom provision files (with relative file path)
    $provision_files.each |String $file| {
      ensure_resource('file', dirname("${repo_path}/${file}"), {'ensure' => 'directory' })
      file { "${repo_path}/${file}":
        ensure => file,
        source => "puppet:///modules/${module_name}/bootstrap/repo/${file}"
      }
    }

    # create ztp json file(s)
    $default_json = { repo_path => $repo_path }
    create_resources('::profile::bootstrap::ztp::json', $ztp_json, $default_json)

  }

}
