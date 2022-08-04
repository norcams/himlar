# rsyslog server
class profile::logging::rsyslog::server(
  $manage_firewall = true,
  $manage_sysconfig = false,
  $manage_log_dir = false,
  $domains = lookup('domain_mgmt', String, 'first'),
  $firewall_extras = {},
  $modules         = {},
  $global_config   = {},
  $legacy_config   = {},
  $inputs          = {},
  $rulesets        = {},
  $templates       = {},
) {

  class { 'rsyslog::config' :
    modules       => $modules,
    global_config => $global_config,
    legacy_config => $legacy_config,
    inputs        => $inputs,
    rulesets      => $rulesets,
    templates     => $templates,
  }

  if $manage_sysconfig {
    file { '/etc/sysconfig/rsyslog':
      content => template("${module_name}/logging/rsyslog/default.erb")
    }
  }
  if $manage_firewall {

    profile::firewall::rule { '150 rsyslog accept udp':
      dport        => [ 514 ],
      destination => $::ipaddress_mgmt1,
      proto       => 'udp',
      extras      => $firewall_extras,
    }

    profile::firewall::rule { '150 rsyslog accept tcp':
      dport        => [ 514 ],
      destination => $::ipaddress_mgmt1,
      proto       => 'tcp',
      extras      => $firewall_extras,
    }
  }

  if $manage_log_dir {
    file { '/opt/log':
      ensure  => directory,
      owner   => 'root',
      seltype => 'var_log_t'
    }
  }

}
