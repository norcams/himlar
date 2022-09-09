# Class: profile::base::hostname
#
# Set hostname 
#
class profile::base::hostname(
  $manage_hostname = false,
) {

  $domain_mgmt = lookup('domain_mgmt', String, 'first', $::domain)
  $hostname = "${::verified_host}.${domain_mgmt}"
  if fact('os.distro.codename') == 'wheezy' {
    file { '/etc/hostname':
      ensure  => 'file',
      mode    => '0644',
      content => "${hostname}\n",
      notify  => Exec['set wheezy hostname']
    }
    exec { 'set wheezy hostname':
      command     => "/bin/hostname ${hostname}",
      refreshonly => true
    }
  } elsif (fact('os.distro.codename') == 'jessie') or (fact('os.distro.codename') == 'stretch') or (fact('os.distro.codename') == 'buster') {
    exec { 'set debian hostname':
      command => "/usr/bin/hostnamectl set-hostname ${hostname}",
      unless  => "/usr/bin/hostnamectl status | grep 'Static hostname: ${hostname}'",
    }
  } elsif $::osfamily == 'RedHat' {
    exec { 'himlar_sethostname':
      command => "/usr/bin/hostnamectl set-hostname ${hostname}",
      unless  => "/usr/bin/hostnamectl status | grep 'Static hostname: ${hostname}'",
    }
  }
}
