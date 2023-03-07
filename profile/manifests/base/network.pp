#
class profile::base::network(
  $manage_network   = true,
  $manage_dummy     = false,
  $net_ifnames      = true,
  $no_of_dummies    = 1,
  $netif_proxy_arp  = false,
  $proxy_arp_ifs    = {},
  $remove_route     = false,
  $remove_route_ifs = undef,
  $l3_router        = false,
  $node_multinic    = false,
  $has_servicenet   = false,
  $cumulus_ifs      = false,
  $cumulus_merge_strategy = 'deep',
  $manage_neutron_blackhole = false,
  $opx_cleanup      = false,
) {

  # Set up extra logical fact names for network facts
  include ::named_interfaces

  include ::network

  if $manage_network {

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

    # Set proxy arp for interface
    if $netif_proxy_arp {
      $proxy_arp_ifs.each |$ifsetsysctl| {
        sysctl::value { "net.ipv4.conf.${ifsetsysctl}.proxy_arp":
          value => 1,
        }
        sysctl::value { "net.ipv6.conf.${ifsetsysctl}.proxy_ndp":
          value => 1,
        }
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
      $named_interface_hash = lookup('named_interfaces::config', Hash, 'deep', {})
      $node_interface_hash = lookup('network::interfaces_hash', Hash, 'first', {})
      # Extract our service interface, then som basic info for that interface
      $service_if = $named_interface_hash[service]
      $service_gateway = $node_interface_hash["$service_if"][gateway]
      $service_ifaddr = $node_interface_hash["$service_if"][ipaddress]
      $service_ifmask = $node_interface_hash["$service_if"][netmask]
      $transport_network = lookup('network_transport', String, 'first', '')

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

    #
    # If the interfaces_hash is empty, create interface files based on certname on RedHat based platforms
    #
    if String(lookup('network::interfaces_hash', Hash, 'deep', {})) == "{}" and $::osfamily == 'RedHat' {
      $addresslist = lookup('profile::network::services::dns_records', Hash, 'deep', '')
      $cname = $addresslist['CNAME'][$::clientcert]
      if empty($cname) {
        $mgmtaddress = $addresslist['A'][$::clientcert]
      }
      else {
        $mgmtaddress = $addresslist['A'][$cname]
      }

      # Create interface files only if an A record is defined in hiera
      # to avoid destroying existing network interfaces config
      unless empty($mgmtaddress) {
        $mgmtnetwork = lookup("netcfg_mgmt_netpart", String, 'first', '')
        $addrbase = regsubst($mgmtnetwork, '^(\d+)\.(\d+)\.(\d+)$','\3',)
        $ouraddr = regsubst($mgmtaddress, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\3',)
        $ipbyte = regsubst($mgmtaddress, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\4',)
        # our third octet might be higher than base, we need to know the difference
        $addrdiff = $ouraddr-$addrbase
        # Find which interfaces to configure and their options
        $named_interfaces_hash = lookup('named_interfaces::config', Hash, 'first', {})
        $ifopts = lookup('profile::base::network::network_auto_opts', Hash, 'deep', {})
        # Configure each interface
        $named_interfaces_hash.each |$ifrole, $ifnamed| {
          $ifname = String($ifnamed[0])

          # We must avoid duplicate interface files for logical constructs in named_interfaces, i.e trp vs transport, live etc
          # Make interface files only for interfaces defined with network_auto_opts
          if $ifopts[$ifrole] {
            # Calculate ip address pr interface based on mgmt address, get gw and mask
            $ipnetpart = lookup("netcfg_${ifrole}_netpart", String, 'first', '')
            $cnet = regsubst($ipnetpart, '^(\d+)\.(\d+)\.(\d+)$','\3',) + $addrdiff
            $netrole= regsubst($ipnetpart, '^(\d+)\.(\d+)\.(\d+)$','\2',)
            $newipaddr = regsubst($mgmtaddress, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$',"\\1.${netrole}.${cnet}.\\4",)
            $ifmask = lookup("netcfg_${ifrole}_netmask", String, 'first', '')
            $ifgw = lookup("netcfg_${ifrole}_gateway", String, 'first', '')

            # check for IPv6 configuration in options for this interface
            if $ifopts[$ifrole]['ipv6init'] == 'yes' {
              # Find network and diff from base
              $ipnetpart6 = lookup("netcfg_${ifrole}_netpart6", String, 'first', '')
              if String($addrdiff) != '0' {
                $newipaddr6 = "${ipnetpart6}::${addrdiff}:${ipbyte}"
              }
              else {
                $newipaddr6 = "${ipnetpart6}::${ipbyte}"
              }
              $ifmask6 = lookup("netcfg_${ifrole}_netmask6", String, 'first', '')
              $ifgw6 = lookup("netcfg_${ifrole}_gateway6", String, 'first', '')
            }

            # Type in ifcg-file can always be "Ehternet" on the el7 platform
            $ifdevtype = 'Ethernet'

            # Check for teaming or bonding
            if (($ifname[0,4] == 'team') or ($ifname[0,4] == 'bond')) and !('.' in $ifname) {
              # Determine type and create slave interfaces
              $iftype = $ifname[0,4]
              $ifslaves = lookup('profile::base::network::network_auto_bonding', Hash, 'first', {})
              $ifslaves[$ifrole].each |$slave, $slaveopts| {
                file { "ifcfg-${slave})":
                  ensure  => file,
                  content => template("${module_name}/network/auto-if-${iftype}slave.erb"),
                  path    => "/etc/sysconfig/network-scripts/ifcfg-${slave}",
                }
              }
            }

            # check for VLAN interface
            if '.' in $ifname {
              $ifvlan = "yes"
            }

            # Write interface file
            file { "ifcfg-${ifname})":
              ensure  => file,
              content => template("${module_name}/network/auto-if.erb"),
              path    => "/etc/sysconfig/network-scripts/ifcfg-${ifname}",
            }
          }
        }
      }
    }

    # Create extra routes, tables, rules on ifup
    create_resources(network::mroute, lookup('profile::base::network::mroute', Hash, 'deep', {}))
    create_resources(network::routing_table, lookup('profile::base::network::routing_tables', Hash, 'deep', {}))
    create_resources(network::route, lookup('profile::base::network::routes', Hash, 'first', {}))
    unless $manage_neutron_blackhole {
      create_resources(network::rule, lookup('profile::base::network::rules', Hash, 'deep', {}))
    } else {
      $named_interface_hash = lookup('named_interfaces::config', Hash, 'first', {})
      $transport_if = $named_interface_hash["trp"][0] # FIXME should cater for many interfaces
      $rules_hash = lookup('profile::base::network::rules', Hash, 'deep', {})
      $trp_rules = $rules_hash["${transport_if}"]['iprule']
      if $rules_hash["${transport_if}"]['iprule6'] {
        $trp_rules6 = $rules_hash["${transport_if}"]['iprule6']
      }
      $neutron_subnets = lookup('profile::openstack::resource::subnets', Hash, 'first', {})
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

    # What were they thinking...
    if $opx_cleanup {
      file { 'remove-eth0':
        ensure => 'absent',
        path   => '/etc/network/interfaces.d/eth0',
      }
      # they even configured the interfaces file...
      file { 'opx-interfaces':
        ensure  => file,
        path    => '/etc/network/interfaces',
        content => "# interfaces(5) file used by ifup(8) and ifdown(8)\r\n# Include files from /etc/network/interfaces.d:\r\n\r\nsource /etc/network/interfaces.d/*.cfg\r\n"
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

      # We use the same merge strategy for all cumulus config. If you change strategy check all of them!
      create_resources(cumulus_interface, lookup('profile::base::network::cumulus_interfaces', Hash, $cumulus_merge_strategy, {}))
      create_resources(cumulus_bridge, lookup('profile::base::network::cumulus_bridges', Hash, $cumulus_merge_strategy, {}))
      create_resources(cumulus_bond, lookup('profile::base::network::cumulus_bonds', Hash, $cumulus_merge_strategy, {}))

      # Check for Cumulus Management VRF, enable if disabled
      case $::operatingsystemmajrelease {
        '2': {
          exec { "cl-mgmtvrf --enable":
            path    => "/usr/bin:/usr/sbin:/bin",
            unless  => "cl-mgmtvrf --status",
            onlyif  => [ 'test -e /etc/network/interfaces.d/eth0', 'test -e /etc/network/if-up.d/z90-route-eth0' ],
            require => Package['cl-mgmtvrf']
          }
        }
        '3': {
          service { 'ntp@mgmt':
            ensure => running,
            enable => true,
          }
        }
        '4': {
          service { 'ntp@mgmt':
            ensure => stopped,
            enable => false,
          }
        }
        default: {
        }
      }
    }
  }
}
