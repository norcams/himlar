#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/apt'
#   mod 'nanliu/staging'
#   mod 'puppetlabs/rabbitmq
#
class profile::messaging::rabbitmq (
  $users            = {},
  $vhosts           = {},
  $exchanges        = {},
  $user_permissions = {},
  $plugins          = {},
  $policy           = {},
  $manage_rsyslog   = false,
  $manage_firewall  = true,
  $firewall_extras  = {},
  $rsyslog_facility = 'local6'
) {

  #Class['rabbitmq'] -> Rabbitmq_vhost <<| |>>
  #Class['rabbitmq'] -> Rabbitmq_user <<| |>>
  #Class['rabbitmq'] -> Rabbitmq_user_permissions <<| |>>
  #Class['rabbitmq'] -> Rabbitmq_exchange <<| |>>
  #Class['rabbitmq'] -> Rabbitmq_plugin <<| |>>

  include ::rabbitmq
  create_resources('rabbitmq_user', $users)
  create_resources('rabbitmq_vhost', $vhosts)
  create_resources('rabbitmq_exchange', $exchanges)
  create_resources('rabbitmq_user_permissions', $user_permissions)
  create_resources('rabbitmq_plugin', $plugins)
  create_resources('rabbitmq_policy', $policy)

  if $manage_firewall {
    profile::firewall::rule { '201 rabbitmq accept tcp':
      port   => 5672,
      extras => $firewall_extras
    }
    profile::firewall::rule { '201 rabbitmq-mgmt accept tcp':
      port   => 15672,
      extras => $firewall_extras
    }
    profile::firewall::rule { '201 rabbitmq-ednp accept tcp':
      port   => 25672,
      extras => $firewall_extras
    }
    profile::firewall::rule { '201 rabbitmq-epmd accept tcp':
      port   => 4369,
      extras => $firewall_extras
    }
    profile::firewall::rule { '201 rabbitmq-cluster accept tcp':
      port   => [ 35197, 35198, 35199 ],
      extras => $firewall_extras
    }
  }

  if $manage_rsyslog {
    rsyslog::imfile { 'rabbitmq':
      file_name     => "/var/log/rabbitmq/rabbit@${::hostname}.log",
      file_tag      => 'rabbitmq',
      file_facility => $rsyslog_facility,
    }
  }

}
