# Enable nova account for ssh migration
class profile::openstack::compute::migration(
  $enable_nova_account = false
) {
  if $enable_nova_account {
    user { 'nova':
      shell   => '/bin/bash',
      require => Package['nova-common']
    }
  }

}
