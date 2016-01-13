#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/java'
#   mod 'puppetlabs/apt'
#   mod 'yguenane/jpackage'
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/concat'
#   mod 'nanliu/staging'
#   mod 'puppetlabs/tomcat'
#   mod 'opentable/jenkins_job_builder'
#
class profile::application::jenkins (
  $install_jjb    = false,
  $jenkins_home   = '/var/lib/jenkins',
  $branch         = 'war-stable',
  $version        = 'latest',
  $catalina_base  = '/usr/share/tomcat',
  $proxy          = false,
  $proxy_vhost    = {},
  $extra_packages = {},
) {

  include profile::webserver::tomcat

  $war_source = "http://mirrors.jenkins-ci.org/${branch}/${version}/jenkins.war"

  $config_file = $::osfamily ? {
    'Debian' => '/etc/default/tomcat',
    default  => '/etc/sysconfig/tomcat',
  }

  file { $jenkins_home :
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0755',
    require => Group['tomcat'],
  }
    
  tomcat::setenv::entry { 'JENKINS_HOME' :
    value       => $jenkins_home,
    config_file => $config_file,
  }

  tomcat::war { 'jenkins.war' :
    war_source    => $war_source,
    catalina_base => $catalina_base,
  }

  if $install_jjb {
    include ::jenkins_job_builder
  }

  if $extra_packages {
    create_resources('package', $extra_packages)
  }

  if $proxy {
    include ::apache
    create_resource('apache::vhost', $proxy_vhost)
  }

}
