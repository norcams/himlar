#
# Skyline dashboard (skyline-apiserver + skyline-console)
#
# This profile is the Skyline counterpart of profile::openstack::dashboard
# and is meant to give the same user experience as our Horizon setup:
#
#   * the same set of policy overrides (/etc/skyline/policy/*_policy.yaml)
#   * the same firewall/network restrictions
#   * the same session database backend (MariaDB on the regional db)
#   * WebSSO (Feide/dataporten) as the default login method
#
# Skyline has no puppet module upstream, so everything is managed here.
#
# Install methods:
#   'venv'    - install wheels (built from our own skyline-console fork) into
#               a virtualenv. Skyline needs python >= 3.10 while el9 still
#               ships 3.9 as the system python, so we build the venv from the
#               python3.11 appstream package. It also keeps skyline's pinned
#               fastapi/pydantic/sqlalchemy away from the system python where
#               the openstack clients live.
#   'package' - install rpms, packages are listed in $packages
#
class profile::openstack::skyline (
  $manage_skyline       = false,
  $manage_nginx         = true,
  $manage_firewall      = false,
  $manage_firewall6     = false,
  $ports                = [80, 443],
  $allow_from_network   = undef,
  $allow_from_network6  = undef,
  $firewall_extras      = {},
  $install_method       = 'venv',
  $packages             = {},
  # name => { source => <wheel path, url or pypi name>, version => <optional> }
  $wheels               = {},
  $python_package       = 'python3.11',
  $venv_dir             = '/opt/skyline',
  $bin_dir              = undef,
  $config_dir           = '/etc/skyline',
  $log_dir              = '/var/log/skyline',
  $run_dir              = '/var/lib/skyline',
  $user                 = 'skyline',
  $group                = 'skyline',
  $bind_address         = '127.0.0.1',
  $bind_port            = 28000,
  $workers              = 4,
  $gunicorn_extra       = {},
  $nginx_listen_address = '0.0.0.0:443',
  $nginx_config_file    = '/etc/nginx/nginx.conf',
  $nginx_user           = 'nginx',
  $server_name          = $::fqdn,
  $ssl_cert             = undef,
  $ssl_key              = undef,
  # Our leaf certs are signed by the intermediate CA. Apache takes the chain
  # as a separate file (horizon::ssl_ca), nginx has no such directive and
  # wants the intermediate concatenated after the leaf in ssl_certificate,
  # so we build a bundle. Set to undef to serve the bare cert.
  $ssl_chain            = undef,
  $ssl_bundle           = undef,
  $region               = $::location,
  $nginx_prefix         = 'api/openstack',
  $proxy_endpoints      = {},
  $manage_db_sync       = false,
  $maintenance_page     = false,
  # Where the console wheel unpacks its static files. Defaults to the venv,
  # an rpm install would put it under /usr/lib instead.
  $console_static_path  = undef,
) {

  $bin_dir_real = $bin_dir? {
    undef   => "${venv_dir}/bin",
    default => $bin_dir,
  }
  $console_static_path_real = $console_static_path? {
    undef   => "${venv_dir}/lib/${python_package}/site-packages/skyline_console/static",
    default => $console_static_path,
  }

  # What nginx actually serves as ssl_certificate: the leaf on its own, or the
  # leaf with the intermediate appended when we have a chain.
  $ssl_bundle_real = $ssl_bundle? {
    undef   => "/etc/pki/tls/certs/${server_name}.chained.pem",
    default => $ssl_bundle,
  }
  $nginx_ssl_cert = ($ssl_cert and $ssl_chain)? {
    true    => $ssl_bundle_real,
    default => $ssl_cert,
  }

  # /etc/skyline/skyline.yaml. Looked up with a deep merge (and not as a class
  # parameter) so a location or a role variant only has to override the single
  # keys it cares about, the same way we do with the policy hash below.
  $config = lookup('profile::openstack::skyline::config', Hash, 'deep', {})

  if $manage_skyline {

    case $install_method {
      'venv': {
        ensure_packages([$python_package], { 'ensure' => 'present' })

        exec { 'skyline venv':
          command => "/usr/bin/${python_package} -m venv ${venv_dir}",
          creates => "${venv_dir}/bin/python",
          require => Package[$python_package],
        }

        # Upgrading is a matter of bumping "version" in hiera. Without a
        # version we only check that the wheel is installed at all, which is
        # what you want when tracking a moving "latest" build.
        $wheels.each |String $wheel, Hash $opts| {
          $source  = $opts['source']? { undef => $wheel, default => $opts['source'] }
          $version = $opts['version']
          # No "grep -q" here: it closes the pipe early and pip then logs a
          # broken pipe error. Plain grep reads all of it and stays quiet.
          $check   = $version? {
            undef   => "${venv_dir}/bin/pip show ${wheel}",
            default => "${venv_dir}/bin/pip show ${wheel} | grep -x 'Version: ${version}' > /dev/null",
          }
          exec { "skyline pip install ${wheel}":
            command  => "${venv_dir}/bin/pip install --upgrade ${source}",
            unless   => $check,
            path     => ['/usr/bin', '/bin'],
            provider => 'shell',
            timeout  => 900,
            tag      => 'skyline_install',
            require  => Exec['skyline venv'],
            notify   => Service['skyline-apiserver'],
          }
        }
      }
      'package': {
        create_resources('package', $packages, { 'ensure' => 'present', 'tag' => 'skyline_install' })
      }
      default: {
        fail("invalid install_method '${install_method}': choose from venv or package")
      }
    }

    # Whatever the install method, skyline has to be on disk before we try to
    # run alembic or start the service
    Exec <| tag == 'skyline_install' |>    -> Service['skyline-apiserver']
    Package <| tag == 'skyline_install' |> -> Service['skyline-apiserver']

    group { $group:
      ensure => present,
      system => true,
    } ->
    user { $user:
      ensure => present,
      gid    => $group,
      shell  => '/sbin/nologin',
      home   => $run_dir,
      system => true,
    }

    file { [$config_dir, "${config_dir}/policy", $log_dir, $run_dir]:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0750',
      require => User[$user],
    }

    # /etc/skyline/skyline.yaml is built from the "config" hash. The hash is
    # deep merged in hiera so a location can override single keys only.
    file { "${config_dir}/skyline.yaml":
      ensure    => file,
      owner     => $user,
      group     => $group,
      mode      => '0640',
      show_diff => false,
      content   => to_yaml($config),
      require   => File[$config_dir],
      notify    => Service['skyline-apiserver'],
    }

    file { "${config_dir}/gunicorn.py":
      ensure  => file,
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => template("${module_name}/openstack/skyline/gunicorn.py.erb"),
      require => File[$config_dir],
      notify  => Service['skyline-apiserver'],
    }

    file { '/etc/systemd/system/skyline-apiserver.service':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/openstack/skyline/skyline-apiserver.service.erb"),
      notify  => [Exec['skyline systemd daemon-reload'], Service['skyline-apiserver']],
    }

    exec { 'skyline systemd daemon-reload':
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
      before      => Service['skyline-apiserver'],
    }

    # Populate the skyline database. Only needed once, and only when we use
    # a real database backend (the regional MariaDB). Upstream runs this as
    # "make db_sync" from a source checkout, we ship the alembic config
    # ourselves instead (script_location is a package path, not a directory).
    if $manage_db_sync {
      file { "${config_dir}/alembic.ini":
        ensure  => file,
        owner   => $user,
        group   => $group,
        mode    => '0644',
        content => template("${module_name}/openstack/skyline/alembic.ini.erb"),
        require => File[$config_dir],
      } ->
      exec { 'skyline db sync':
        command     => "${bin_dir_real}/alembic -c ${config_dir}/alembic.ini upgrade head && touch ${run_dir}/.db_sync",
        path        => [$bin_dir_real, '/usr/bin', '/bin'],
        user        => 'root',
        environment => ["OS_CONFIG_DIR=${config_dir}"],
        creates     => "${run_dir}/.db_sync",
        require     => File["${config_dir}/skyline.yaml"],
        before      => Service['skyline-apiserver'],
      }

      Exec <| tag == 'skyline_install' |>    -> Exec['skyline db sync']
      Package <| tag == 'skyline_install' |> -> Exec['skyline db sync']
    }

    service { 'skyline-apiserver':
      ensure  => running,
      enable  => true,
      require => File["${config_dir}/skyline.yaml"],
    }

    if $manage_nginx {
      ensure_packages(['nginx'], { 'ensure' => 'present' })

      # nginx sends whatever is in ssl_certificate and nothing else, so a leaf
      # signed by our intermediate has to be shipped with the intermediate
      # appended or the browser cannot build a path to the root. Rebuilt
      # whenever either input is newer than the bundle.
      if $ssl_cert and $ssl_chain {
        # The bundle is written with "cat a b > bundle", and the shell
        # truncates the target before cat reads anything. If the bundle were
        # one of the inputs we would destroy it - cachain.pem in particular is
        # also the cafile skyline uses to reach keystone. Refuse rather than
        # eat it.
        if $ssl_bundle_real in [$ssl_cert, $ssl_chain] {
          fail("profile::openstack::skyline: ssl_bundle (${ssl_bundle_real}) must differ from ssl_cert and ssl_chain, it is overwritten with their contents")
        }

        # In vagrant the leaf is signed by profile::application::openssl::cert
        # in this same run. Without this the bundle can be built before the
        # cert exists, silently skip, and leave nginx pointing at a file that
        # is never created. Matches nothing when certs are pre-placed.
        Exec <| title == "sign ${server_name}" |> -> Exec['skyline ssl bundle']

        exec { 'skyline ssl bundle':
          command  => "cat ${ssl_cert} ${ssl_chain} > ${ssl_bundle_real}",
          onlyif   => "test -f ${ssl_cert} && test -f ${ssl_chain}",
          unless   => "test -f ${ssl_bundle_real} && test ${ssl_bundle_real} -nt ${ssl_cert} && test ${ssl_bundle_real} -nt ${ssl_chain}",
          path     => ['/usr/bin', '/bin'],
          provider => 'shell',
          before   => Service['nginx'],
          notify   => Service['nginx'],
        }
      }

      file { $nginx_config_file:
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/openstack/skyline/nginx.conf.erb"),
        require => Package['nginx'],
        notify  => Service['nginx'],
      }

      # To use this:
      # - enable this block with $maintenance_page = true (this can be done permanently)
      # - touch /var/www/maintenance to show page
      # - rm /var/www/maintenance to remove the page
      if $maintenance_page {
        # Unlike the horizon node there is no apache here to create /var/www,
        # nginx serves out of /usr/share/nginx/html
        file { '/var/www':
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        } ->
        file { 'skyline_maintenance.html':
          ensure  => file,
          path    => '/var/www/maintenance.html',
          source  => "puppet:///modules/${module_name}/openstack/horizon/maintenance.html",
          require => Package['nginx'],
          notify  => Service['nginx'],
        }
      }

      service { 'nginx':
        ensure  => running,
        enable  => true,
        require => Package['nginx'],
      }

      # nginx resolves the proxy_pass hostnames when it reads the config and
      # refuses to start if one of them is unknown. In vagrant the api names
      # come from /etc/hosts (profile::development::network::dns), so make
      # sure they are in place first. No-op everywhere else.
      Host <| |> -> Service['nginx']
    }

    # Policy overrides, same pattern as profile::openstack::dashboard. Files
    # are named <service>_policy.yaml and are re-read by the api server when
    # they change, so no service restart is needed.
    $policy_defaults = {
      require     => File["${config_dir}/policy"],
      file_mode   => '0644',
      file_format => 'yaml',
    }
    $policies = lookup('profile::openstack::skyline::policies', Hash, 'deep', {})
    create_resources('openstacklib::policy::base', $policies, $policy_defaults)
  }

  if $manage_firewall {
    $hiera_allow_from_network = lookup('allow_from_network', Array, 'unique', undef)
    $source = $allow_from_network? {
      undef   => $hiera_allow_from_network,
      ''      => $hiera_allow_from_network,
      default => $allow_from_network
    }
    profile::firewall::rule { '236 public openstack-skyline accept tcp':
      dport  => $ports,
      source => $source,
      extras => $firewall_extras,
    }
  }

  if $manage_firewall6 {
    $hiera_allow_from_network6 = lookup('allow_from_network6', Array, 'unique', [])
    $source6 = $allow_from_network6? {
      undef   => $hiera_allow_from_network6,
      ''      => $hiera_allow_from_network6,
      default => $allow_from_network6,
    }
    profile::firewall::rule { '236 public openstack-skyline accept tcp6':
      dport    => $ports,
      source   => $source6,
      extras   => $firewall_extras,
      provider => 'ip6tables',
    }
  }

}
