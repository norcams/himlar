# This class is included from common.pp if is_virtual is false
# and manufacturer is Dell
#
# The class does the following:
#   - Installs the Dell yum repos
#   - Installs Dell Openmanage packages
#   - Installs SNMP daemon (net-snmp)
#   - Opens up the SNMP port (161/UDP) in the firewall
#   - Ensures that Openmanage and SNMP services are running
#
class profile::base::dell (
  $snmp_firewall_settings = {},
  $manage_repos      = false,
  $manage_openmanage = false,
){
  if fact('dmi.product.name') =~ '^PowerEdge (FC|[RTM])[1-9][1-6]\d.*' {

    if $manage_repos {

      # find Dell yum repos
      $repo_hash = lookup('profile::base::dell::repo_hash', Hash, 'deep', {})

      # Install repos
      create_resources('yumrepo', $repo_hash)
    }

    if $manage_openmanage {

      # get Dell packages
      $packages = lookup('profile::base::dell::packages', Hash, 'deep', {})

      # Install packages
      create_resources('profile::base::package', $packages)

      # SNMP daemon
      service { "snmpd":
        ensure  => running,
        enable  => true,
      }

      # OMSA daemons
      service { "instsvcdrv":
        ensure => running,
        enable => true,
      } ->
      service { "dataeng":
        ensure => running,
        enable => true,
      } ->
      service { "dsm_om_connsvc":
        ensure => running,
        enable => true,
      } ->
      service { "dsm_om_shrsvc":
        ensure => running,
        enable => true,
      }

      # Configure snmpd.conf
      #exec { "enable snmp":
      #  command => "/etc/init.d/dataeng enablesnmp",
      #  unless  => "/bin/grep -q ^smuxpeer /etc/snmp/snmpd.conf",
      #  notify  => Service['snmpd'],
      #}

      if $::runmode == 'default' {
        # Open the SNMP port (161/UDP) in the firewall
        profile::firewall::rule { '001 allow SNMP':
          dport  => 161,
          proto  => 'udp',
          extras => $snmp_firewall_settings,
        }
      }
    }
  }
}
