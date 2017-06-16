#
class profile::base::network(
  $manage_dummy     = false,
  $net_ifnames      = true,
  $no_of_dummies    = 1,
  $manage_httpproxy = false,
  $http_proxy       = undef,
  $remove_route     = false,
  $remove_route_ifs = undef,
  $l3_router        = false,
  $node_multinic    = false,
  $has_servicenet   = false,
  $cumulus_ifs      = false,
  $http_proxy_profile = '/etc/profile.d/proxy.sh',
  $manage_neutron_blackhole = false,
  $manage_hostname  = false
) {

  # Set up extra logical fact names for network facts
  include ::named_interfaces

  # example42 network module or bsd
  if $::osfamily == 'FreeBSD' {
    include ::bsd::network
    include ::resolv_conf

    shellvar { "Load bsd tap device":
      ensure   => present,
      target   => "/etc/rc.conf",
      variable => "cloned_interfaces",
      value    => "tap0",
    }

    create_resources(bsd::network::interface, hiera('network::interfaces_hash', {}))

  } else {
    include ::network
  }

  if $manage_hostname {
    $domain_mgmt = hiera('domain_mgmt', $::domain)
    $hostname = "${::hostname}.${domain_mgmt}"
    if $::osfamily == 'RedHat' {
      exec { 'himlar_sethostname':
        command => "/usr/bin/hostnamectl set-hostname ${hostname}",
        unless  => "/usr/bin/hostnamectl status | grep 'Static hostname: ${hostname}'",
      }
    }
  }

  # - Set ifnames=0 and use old ifnames, e.g 'eth0'
  # - Use biosdevname on physical servers, e.g 'em1'
  if $net_ifnames {
    kernel_parameter { "net.ifnames":
      ensure => present,
      value  => "0",
    }
  }

  # Persistently install dummy module
  if $manage_dummy {
    include ::kmod
    kmod::load { "dummy": }

    kmod::option { "Number of dummy interfaces":
      module => "dummy",
      option => "numdummies",
      value =>  $no_of_dummies,
    }
  }

  # Delete link routes on ifup
  if $remove_route {
    file { '/sbin/ifup-local':
      owner   => 'root',
      group   => 'root',
      mode    => '0754',
      content => template("${module_name}/network/ifup-local.erb"),
    }
  }

  # In order to route to tap interfaces, ip forwarding must be enabled
  if $l3_router {
    sysctl::value { "net.ipv4.ip_forward":
      value => 1,
    }
    sysctl::value { "net.ipv6.conf.all.forwarding":
      value => 1,
    }
  }

  if $node_multinic {
    sysctl::value { "net.ipv4.conf.all.rp_filter":
      value => 2,
    }
  }

  # Nodes with service network will get requests from IPs on an another subnet,
  # but default route is not through the service interface. We must create
  # a custom iproute2 table for the service interface. Our custom named_interfaces
  # facts can not be used as these rules must be created in our initial kickstart run
  if $has_servicenet { #FIXME
    # Get our named and node interfaces hashes
    $named_interface_hash = hiera_hash('named_interfaces::config')
    $node_interface_hash = hiera_hash('network::interfaces_hash')
    # Extract our service interface, then som basic info for that interface
    $service_if = $named_interface_hash[service]
    $service_gateway = $node_interface_hash["$service_if"][gateway]
    $service_ifaddr = $node_interface_hash["$service_if"][ipaddress]
    $service_ifmask = $node_interface_hash["$service_if"][netmask]
    $transport_network = hiera('network_transport')

    # Create a custom route table for service interface
    network::routing_table { 'service-net':
      table_id => '100',
    }
    # Create a default route for the service interface
    network::route { $service_if:
      ipaddress => [ '0.0.0.0', ip_address($transport_network), ],
      netmask   => [ '0.0.0.0', ip_netmask($transport_network), ],
      gateway   => [ $service_gateway, $service_gateway, ],
      table     => [ '100', 'main', ]
    }
    # When answering requests to service interface, always send answer on this interface
    network::rule { $service_if:
      iprule => [ "from ${service_ifaddr}/${service_ifmask} lookup service-net", ],
    }
  }

  # Create extra routes, tables, rules on ifup
  create_resources(network::mroute, hiera_hash('profile::base::network::mroute', {}))
  create_resources(network::routing_table, hiera_hash('profile::base::network::routing_tables', {}))
  create_resources(network::route, hiera_hash('profile::base::network::routes', {}))
    if $manage_neutron_blackhole != true {
    create_resources(network::rule, hiera_hash('profile::base::network::rules', {}))
  } else {
    $named_interface_hash = hiera('named_interfaces::config')
    $transport_if = $named_interface_hash[trp]
    $rules_hash = hiera_hash('profile::base::network::rules')
    $trp_rules = $rules_hash["${transport_if}"]['iprule']
    $neutron_subnets = hiera('profile::openstack::resource::subnets')
    file { "rule-${transport_if}":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      path    => "/etc/sysconfig/network-scripts/rule-${transport_if}",
      content => template("${module_name}/network/rule4-interface.erb"),
    }
    file { "rule6-${transport_if}":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      path    => "/etc/sysconfig/network-scripts/rule6-${transport_if}",
      content => template("${module_name}/network/rule6-interface.erb"),
    }
    file { '/opt/rule-checks/':
      ensure  => directory,
    } ~>
    file { "rule4-rulecheck.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0755',
      path    => "/opt/rule-checks/rule4-check.sh",
      content => template("${module_name}/network/rule4-rulecheck.erb"),
    } ~>
    file { "rule6-rulecheck.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0755',
      path    => "/opt/rule-checks/rule6-check.sh",
      content => template("${module_name}/network/rule6-rulecheck.erb"),
    } ~>
    file { "rule4-enforce.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0755',
      path    => "/opt/rule-checks/rule4-enforce.sh",
      content => template("${module_name}/network/rule4-enforce.erb"),
    } ~>
    file { "rule6-enforce.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0755',
      path    => "/opt/rule-checks/rule6-enforce.sh",
      content => template("${module_name}/network/rule6-enforce.erb"),
    } ~>
    exec { '/opt/rule-checks/rule4-enforce.sh':
      unless  => '/opt/rule-checks/rule4-check.sh',
    } ->
    exec { '/opt/rule-checks/rule6-enforce.sh':
      unless  => '/opt/rule-checks/rule6-check.sh',
    }
  }

  if $manage_httpproxy {
    $ensure_value = $http_proxy ? {
      undef    => absent,
      default => present,
    }
    $target = $http_proxy_profile

    shellvar { "http_proxy":
      ensure  => exported,
      target  => $target,
      value   => $http_proxy,
    }
    shellvar { "https_proxy":
      ensure  => exported,
      target  => $target,
      value   => $http_proxy,
    }
  }

  if $cumulus_ifs {
    # For cumulus interfaces to work, we need a non default interfaces config file
    file { '/etc/network/interfaces':
      owner   => 'root',
      group   => 'root',
      mode    => '0754',
      content => template("${module_name}/network/cl-interfaces.erb"),
    }

    create_resources(cumulus_interface, hiera_hash('profile::base::network::cumulus_interfaces', {}))
    create_resources(cumulus_bridge, hiera_hash('profile::base::network::cumulus_bridges', {}))
    create_resources(cumulus_bond, hiera_hash('profile::base::network::cumulus_bonds', {}))

    # Check for Cumulus Management VRF, enable if disabled
    exec { "cl-mgmtvrf --enable":
      path   => "/usr/bin:/usr/sbin:/bin",
      unless => "cl-mgmtvrf --status",
      onlyif => [ 'test -e /etc/network/interfaces.d/eth0', 'test -e /etc/network/if-up.d/z90-route-eth0' ]
    }
  }
}
