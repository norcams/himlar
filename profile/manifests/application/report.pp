#
class profile::application::report(
  $database_uri,
  $debug              = false,
  $package_url        = false,
  $config_dir         = '/etc/himlar',
  $install_dir        = '/opt/report-app',
  $db_sync            = false,
  $app_version        = 'v1',
  $app_downloaddir    = '/opt/report-utils',
  $report_linkname    = 'report',
  $report_utils       = {},
  $report_utils_url   = 'https://report.nrec.no/api/v1/instance'
) {

  if $package_url {
    package { 'report-app':
      ensure   => 'present',
      provider => 'rpm',
      source   => $package_url,
      notify   => Class['apache::service']
    }
  }

  file { $config_dir:
    ensure => directory
  } ->
  file { "${config_dir}/production.cfg":
    ensure  => file,
    owner   => 'root',
    mode    => '0644',
    content => template("${module_name}/application/report/production.cfg.erb"),
    notify  => Class['apache::service']
  }

  if $db_sync {
    exec { 'create api tables in db':
      command => "${install_dir}/bin/python ${install_dir}/db_manage.py create api && touch ${install_dir}/.api.dbsync",
      require => File["${config_dir}/production.cfg"],
      creates => "${install_dir}/.api.dbsync"
    }
    exec { 'create oauth tables in db':
      command => "${install_dir}/bin/python ${install_dir}/db_manage.py create oauth && touch ${install_dir}/.oauth.dbsync",
      require => File["${config_dir}/production.cfg"],
      creates => "${install_dir}/.oauth.dbsync"

    }
  }

  # create client scripts and links to these
  # (substitutes old report-utils functionality)
  if ! empty($report_utils) {
    file { $app_downloaddir:
      ensure => directory
    }
    # for each distribution ...
    $report_utils.each | Tuple $dist_info | {
      $distribution = $dist_info[0]
      $dist_hash    = $dist_info[1]
      # make sure distribution dir exists
      file { "${app_downloaddir}/${distribution}":
        ensure => directory
      }
      # if data for main dist script is entered then make sure script exists
      if ! empty($dist_hash) {
        # Scripts as files (also create main file!)
        if ( has_key($dist_hash, 'scripts') and ! empty($dist_hash['scripts']) ) {
          $scripts = $dist_hash['scripts']
          # iterate through every script for this distribution
          $scripts.each | String $script_name, Array $fragments | {
            # main script (location)
            concat { "${app_downloaddir}/${distribution}/${script_name}":
              ensure => present,
              owner  => 'root',
              group  => 'root',
              mode   => '0644'
            }
            # ensure script contains configured fragments
            if ! empty($fragments)  {
              $fragments.each | Integer $index, String $fragment | {
                concat::fragment { "${distribution}-${script_name}-${fragment}":
                  target => "${app_downloaddir}/${distribution}/${script_name}",
                  source => "puppet:///modules/${module_name}/applications/report/${fragment}",
                  order  => $index
                }
              }
            }
          }
        }
        # Script as templates
        if ( has_key($dist_hash, 'templates') and ! empty($dist_hash['templates']) ) {
          $templates = $dist_hash['templates']
          # iterate through every script for this distribution
          $templates.each | String $script_name, Array $fragments | {
            # ensure script contains configured fragments
            if ! empty($fragments)  {
              $fragments.each | Integer $index, String $fragment | {
                concat::fragment { "${distribution}-${script_name}-${fragment}":
                  target => "${app_downloaddir}/${distribution}/${script_name}",
                  content => template("${module_name}/application/report/scripts/${fragment}"),
                  order  => Integer(90 + $index)
                }
              }
            }
          }
        }
        # validate that data for any versions of distribution is entered
        if ( has_key($dist_hash, 'versions') and ! empty($dist_hash['versions']) ) {
          $releases = $dist_hash['versions']
          # for each version ensure appropriate directory and script link exists
          $releases.each | $release, $script_name | {
            file { "${app_downloaddir}/${distribution}/${release}":
              ensure => directory
            } ->
            file { "${app_downloaddir}/${distribution}/${release}/${app_version}":
              ensure => directory
            } ->
            file { "${app_downloaddir}/${distribution}/${release}/${app_version}/${report_linkname}":
              ensure => link,
              target => "${app_downloaddir}/${distribution}/${script_name}"
            }
          }
        }
      }
    }
  }
}
