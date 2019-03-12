# Class: profile::storage::cephmon
#
#
class profile::storage::cephmon (
  $dashboard_password,
  $dashboard_user       = 'admin',
  $manage_dashboard     = false,
  $crt_dir              = '/etc/pki/tls/certs',
  $key_dir              = '/etc/pki/tls/private',
  $cert_name            = $::fqdn,
  $flagfile             = '/var/lib/ceph/.ceph-dashboard-set-up',
  $create_crushbuckets  = false
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
}
