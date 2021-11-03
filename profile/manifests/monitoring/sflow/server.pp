#
class profile::monitoring::sflow::server (
  $manage_sflow2graphite     = false,
) {

  # Install tools for converting sflow data
  if $manage_sflow2graphite {
    file { 'sflowtool':
      ensure => file,
      path   => '/usr/local/bin/sflowtool',
      source => 'https://iaas-repo.uio.no/uh-iaas/rpm/sflowtool',
      owner  => 'root',
      mode   => '0755',
    }
    file { 'sflow2graphite.pl':
      ensure => file,
      path   => '/usr/sbin/sflow2graphite.pl',
      source => 'https://iaas-repo.uio.no/uh-iaas/rpm/sflow2graphite.pl',
      owner  => 'root',
      mode   => '0755',
    }
  }
}

