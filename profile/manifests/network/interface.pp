# Class: profile::network::interface
#
# Automatically generate interface files based on node name defined in common.yaml
# or create interface files from interfaces_hash by the network module
#
class profile::network::interface(
  $manage_interface         = false,
  $suppress_legacy_warning  = false, # el8 only
  $create_custom_routes     = false,
  $create_ip_rules          = false,
  $rule_merge_strategy      = 'deep',
  $manage_neutron_blackhole = false,
  $manage_dummy             = false,
  $no_of_dummies            = 1,
) {

  # Set up extra logical fact names for network facts
  include ::named_interfaces

  include ::network

  # Remove annoying deprecation message for el8 legacy network scripts
  if $suppress_legacy_warning {
    shellvar { 'DEPRECATION_WARNING_ISSUED':
      ensure  => exported,
      target  => '/etc/profile.d/suppress_legacy_warning.sh',
      value   => true
    }
  }

  # Persistently install dummy module
  if $manage_dummy {
    include ::kmod
    kmod::load { "dummy": }

    kmod::option { "Number of dummy interfaces":
      module  => "dummy",
      option  => "numdummies",
      value   => $no_of_dummies,
      notify  => Exec['rebuild initramfs']
    }
    # Remove override in el8 installs
    file_line { 'remove_dummy_override':
      path    => '/lib/modprobe.d/systemd.conf',
      line    => '#options dummy numdummies=0',
      match   => 'options dummy numdummies=0',
      replace => true,
      notify  => Exec['rebuild initramfs']
    }
    exec { 'rebuild initramfs':
      command     => 'dracut -f --kver $(rpm -qa kernel | sort -V -r | head -n 1 | sed \'s|kernel-||\')',
      path        => '/sbin:/usr/bin:/usr/sbin',
      refreshonly => true
    }
  }

  # Create extra routes, tables, rules on ifup
  if $create_custom_routes {
    if Integer($facts['os']['release']['major']) <= 8 {
      create_resources(network::mroute, lookup('profile::base::network::mroute', Hash, 'deep', {}))
      create_resources(network::routing_table, lookup('profile::base::network::routing_tables', Hash, 'deep', {}))
      create_resources(network::route, lookup('profile::base::network::routes', Hash, 'first', {}))
    }  elsif Integer($facts['os']['release']['major']) >= 9 {
      include network::routing::table
    }
  }
  if Integer($facts['os']['release']['major']) <= 8 {
    if $create_ip_rules {
      unless $manage_neutron_blackhole {
        create_resources(network::rule, lookup('profile::base::network::rules', Hash, $rule_merge_strategy, {}))
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
    }
  } elsif Integer($facts['os']['release']['major']) >= 9 {
    if $manage_neutron_blackhole {
      $transport_if = $named_interfaces::config[trp][0]
      $neutron_subnets = lookup('profile::openstack::resource::subnets', Hash, 'first', {})
      $neutron_subnets.each |$neutron_subnet, $cidr| {
        if $cidr[cidr] =~ Stdlib::IP::Address::V4::CIDR {
          exec { "add blackhole from ${neutron_subnet}":
            command => "/bin/nmcli connection modify ${transport_if} +ipv4.routing-rules \"priority 5 from ${cidr[cidr]} to ${::network_trp1}/${::cidr_trp1} type blackhole\" && echo \"save persistent\" | /bin/nmcli connection edit ${transport_if} || /bin/nmcli connection up ${transport_if}",
            unless => "/bin/test $(/sbin/ip rule show | grep blackhole | grep ${cidr[cidr]} | cut -d ' ' -f 2)"
          }
        } elsif $cidr[cidr] =~ Stdlib::IP::Address::V6::CIDR {
          exec { "add blackhole from ${neutron_subnet}":
            command => "/bin/nmcli connection modify ${transport_if} +ipv6.routing-rules \"priority 5 from ${cidr[cidr]} to ${::network6_trp1}/${::cidr6_trp1} type blackhole\" && echo \"save persistent\" | /bin/nmcli connection edit ${transport_if} || /bin/nmcli connection up ${transport_if}",
            unless => "/bin/test $(/sbin/ip -6 rule show | grep blackhole | grep ${cidr[cidr]} | cut -d ' ' -f 2)"
          }
        }
      }
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
      if Integer($facts['os']['release']['major']) <= 8 {
        $ifopts = lookup('profile::base::network::network_auto_opts', Hash, 'deep', {})
      } elsif Integer($facts['os']['release']['major']) >= 9 {
        $ifopts = lookup('profile::base::network::nm_auto_opts', Hash, 'deep', {})
      }
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
          $ifcidr = extlib::netmask_to_cidr("$ifmask")
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

          # Type in ifcg-file must be set according to actual type of interface
          if !('.' in $ifname){
            if (($ifname[0,4] == 'team') or ($ifname[0,4] == 'bond')) {
              $ifdevtype = $ifname[0,4]
            }
            else {
              $ifdevtype = 'Ethernet'
            }
          }

          # Check for teaming or bonding
          if (($ifname[0,4] == 'team') or ($ifname[0,4] == 'bond')) and !('.' in $ifname) {
            # Determine type and create slave interfaces
            $iftype = $ifname[0,4]
            if Integer($facts['os']['release']['major']) <= 8 {
              $ifslaves = lookup('profile::base::network::network_auto_bonding', Hash, 'first', {})
              $ifslaves[$ifrole].each |$slave, $slaveopts| {
                file { "ifcfg-${slave})":
                  ensure  => file,
                  content => template("${module_name}/network/auto-if-${iftype}slave.erb"),
                  path    => "/etc/sysconfig/network-scripts/ifcfg-${slave}",
                }
              }
            } elsif Integer($facts['os']['release']['major']) >= 9 {
              $connection_type = 'bond'
              $ifslaves = lookup('profile::base::network::nm_network_auto_bonding', Hash, 'first', {})
              $ifslaves[$ifrole].each |$slave, $slaveopts| {
              $slave_if =
                { "$ifname-$slave" =>
                  { 'controller'     => $ifname,
                    'port_type'      => 'bond',
                    'interface_name' => $slave,
                    'id'             => "${ifname}-${slave}"
                  },
                }
                if ($slaveopts[ethernet]) {
                  $slave_if_opts_ethernet = { "${ifname}-${slave}" => { ethernet => $slaveopts[ethernet]}}
                } else {
                  $slave_if_opts_ethernet = {}
                }
                if ($slaveopts[bond-port]) {
                  $slave_if_opts_bond_port = { "${ifname}-${slave}" => { bond-port => $slaveopts[bond-port]}}
                } else {
                  $slave_if_opts_bond_port = {}
                }

                $slave_if_final = deep_merge($slave_if, $slave_if_opts_ethernet, $slave_if_opts_bond_port)
                create_resources ('network::nm::connection',$slave_if_final)
              }
            }
          }

          # check for VLAN interface
          if '.' in $ifname {
            $ifvlan = "yes"
          }

          # Write interface file
          if Integer($facts['os']['release']['major']) <= 8 {
            file { "ifcfg-${ifname})":
              ensure  => file,
              content => template("${module_name}/network/auto-if.erb"),
              path    => "/etc/sysconfig/network-scripts/ifcfg-${ifname}",
            }
          } elsif Integer($facts['os']['release']['major']) >= 9 {

            if $newipaddr6 {
              $nm_ipv6 =
                { 'method'   => 'manual',
                  'address1' => "$newipaddr6/$ifmask6",
                  'gateway'  => "$ifgw6",
                }
            } else {
              $nm_ipv6 = {}
            }

            # NetworkManger will not accept an empty gateway statement
            if $ifgw =~ String[1] {
              $nm_interface =
                { "$ifname" =>
                  { ipv4 =>
                    { 'method'   => 'manual',
                      'address1' => "$newipaddr/$ifcidr",
                      'gateway'  => "$ifgw"
                    },
                    ipv6 => $nm_ipv6,
                  },
                }
            } else {
              $nm_interface =
                { "$ifname" =>
                  { ipv4 =>
                    { 'method'   => 'manual',
                      'address1' => "$newipaddr/$ifcidr",
                    },
                  ipv6 => $nm_ipv6,
                },
              }             
            }

            # routes for NM
            if $create_custom_routes {
              $ifroutes = lookup('profile::base::network::nm_auto_routes', Hash, 'first', {})
              if ($ifroutes[$ifrole]) {
                $nm_interfaces_routes = { $ifname => $ifroutes[$ifrole] }
              } else {
                $nm_interfaces_routes = {}
              }
            } else {
              $nm_interfaces_routes = {}
            }

            if $connection_type == 'bond' {
              $conn_type = { $ifname => { connection_type => 'bond' }}
            } elsif $ifvlan {
              $conn_type = { $ifname => { connection_type => 'vlan' }}
            } else {
              $conn_type = {}
            }

            if $ifvlan {
              $nm_interface_vlan =
              { "$ifname" =>
                { vlan =>
                  { 'id'     => "${split($ifname, '\.')[1]}",
                    'parent' => "${split($ifname, '\.')[0]}",
                    'flags'  => '1'
                  }
                }
              }
            } else {
              $nm_interface_vlan = {}
            }

            if ($ifopts[$ifrole][ipv4]) {
              $nm_interface_ipv4 = { $ifname => { ipv4 => $ifopts[$ifrole][ipv4] }}
            } else {
              $nm_interface_ipv4 = {}
            }
            if ($ifopts[$ifrole][ipv6]) {
              $nm_interface_ipv6 = { $ifname => { ipv6 => $ifopts[$ifrole][ipv6] }}
            } else {
              $nm_interface_ipv6 = {}
            }
            if ($ifopts[$ifrole][ethernet]) {
              $nm_interface_ethernet = { $ifname => { ethernet => $ifopts[$ifrole][ethernet] }}
            } else {
              $nm_interface_ethernet = {}
            }
            if ($ifopts[$ifrole][bond]) {
              $nm_interface_bond = { $ifname => { bond => $ifopts[$ifrole][bond] }}
            } else {
              $nm_interface_bond = {}
            }

            $nm_interface_final = deep_merge($nm_interface, $nm_interface_ipv4, $nm_interface_ipv6, $nm_interfaces_routes, $nm_interface_ethernet, $nm_interface_bond, $nm_interface_vlan, $conn_type)

            create_resources ('network::nm::connection',$nm_interface_final)
          }
        }
      }
    }
  }
}
