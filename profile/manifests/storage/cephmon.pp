# Class: profile::storage::cephmon
#
#
class profile::storage::cephmon (
  $dashboard_password         = undef,
  $dashboard_user             = 'admin',
  $manage_dashboard           = false,
  $crt_dir                    = '/etc/pki/tls/certs',
  $key_dir                    = '/etc/pki/tls/private',
  $cert_name                  = $::fqdn,
  $flagfile                   = '/var/lib/ceph/.ceph-dashboard-set-up',
  $create_crushbuckets        = false,
  $ceph_balancer_active       = undef,
  $ceph_balancer_mode         = undef,
  $create_extraconf           = false,
  $target_max_misplaced_ratio = undef, # WARNING: If set, it will be dynamically configured in the cluster. Increments 0.01, default 0.05
) {
  include ::ceph::profile::mon
  include ::ceph::profile::mgr

  if $create_crushbuckets {
    create_resources(profile::storage::ceph_crushbucket, lookup('profile::storage::ceph_crushbucket::buckets', Hash, 'first', {}))
  }

  if $manage_dashboard {
    ceph_config {
      'mon/mgr initial modules':    value => 'dashboard'
    }
    exec { 'enable dashboard':
      command     => 'ceph mgr module enable dashboard',
      path        => '/usr/bin:/usr/sbin:/bin',
      creates => $flagfile,
    }
      ~>
    exec { 'dashboard.crt':
      command => "ceph dashboard create-self-signed-cert",
      path    => '/usr/bin:/usr/sbin:/bin',
      refreshonly => true,
    }


#    exec { 'dashboard.crt':
#      command => "ceph config-key set mgr/dashboard/crt -i ${crt_dir}/${cert_name}.cert.pem",
#      path    => '/usr/bin:/usr/sbin:/bin',
#      creates => $flagfile,
#    }
#      ~>
#    exec { 'dashboard.key':
#      command     => "ceph config-key set mgr/dashboard/key -i ${key_dir}/${cert_name}.key.pem",
#      path        => '/usr/bin:/usr/sbin:/bin',
#      refreshonly => true,
#    }
      ~>
    exec { 'reload dashboard':
      command     => 'ceph mgr module disable dashboard && ceph mgr module enable dashboard',
      path        => '/usr/bin:/usr/sbin:/bin',
      refreshonly => true,
    }
      ~>
    exec { 'dashboard-user':
      command     => "ceph dashboard set-login-credentials ${dashboard_user} ${dashboard_password} && touch ${flagfile}",
      path        => '/usr/bin:/usr/sbin:/bin',
      refreshonly => true,
    }
  }

  # Optinally set extra config parameters in ceph.conf
  if $create_extraconf {
    create_resources(profile::storage::ceph_extraconf, lookup('profile::storage::ceph_extraconf::config', Hash, 'deep'))
  }

  # Optionally set target for the ceph mgr autobalancer module
  if $target_max_misplaced_ratio {
    exec { "set-max-misplaced-ratio-${name}":
      command  => "ceph config set mgr target_max_misplaced_ratio ${target_max_misplaced_ratio}",
      provider => shell,
      unless   => "test $(ceph config get mgr.${::hostname} target_max_misplaced_ratio | head -c4) == ${target_max_misplaced_ratio}",
    }
  }

  # Set balancer mode
  if $ceph_balancer_mode {
    exec { "set-balancer-mode-${name}":
      command  => "ceph balancer mode ${ceph_balancer_mode}",
      provider => shell,
      unless   => "test $(ceph balancer status | grep mode | awk '{print \$NF}' | tr -dc '[:alnum:]\n\r') == ${ceph_balancer_mode}",
    }
  }

  # activate the ceph balancer module
  if $ceph_balancer_active {
    exec { "enable-balancer":
      command  => "ceph balancer on",
      provider => shell,
      unless   => "test $(ceph balancer status | grep active | awk '{print \$NF}' | tr -dc '[:alnum:]\n\r') == true",
    }
  }
}
