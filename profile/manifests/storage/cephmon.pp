# Class: profile::storage::cephmon
#
#
class profile::storage::cephmon (
  $manage_dashboard     = false,
  $crt_dir              = '/etc/pki/tls/certs',
  $key_dir              = '/etc/pki/tls/private',
  $cert_name            = $::fqdn,
  $dashboard_user       = 'admin',
  $dashboard_password   = undef,
) {
  include ::ceph::profile::mon
  include ::ceph::profile::mgr

  if $manage_dashboard {
    ceph_config {
      'mon/mgr initial modules':    value => 'dashboard'
    }

    exec { 'dashboard.crt':
      command => "ceph config-key set mgr mgr/dashboard/crt -i ${crt_dir}/${cert_name}.crt",
      path    => '/usr/bin:/usr/sbin:/bin',
      creates => '/etc/ceph/.ceph-dashboard-set-up',
    }
     ~>
    exec { 'dashboard.key':
      command     => "ceph config-key set mgr mgr/dashboard/key -i ${key_dir}/${cert_name}.key",
      path        => '/usr/bin:/usr/sbin:/bin',
      refreshonly => 'true',
    }
     ~>
    exec { 'dashboard-user':
      command     => "ceph dashboard set-login-credentials $dashboard_user $dashboard_password && touch /etc/ceph/.ceph-dashboard-set-up",
      path        => '/usr/bin:/usr/sbin:/bin',
      refreshonly => 'true',
    }
  }
}
