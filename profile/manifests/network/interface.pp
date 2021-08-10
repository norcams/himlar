# Class: profile::network::interface
#
# Automatically generate interface files based on node name defined in common.yaml
# or create interface files from interfaces_hash by the network module
#
class profile::network::interface(
  $manage_interface        = false,
  $suppress_legacy_warning = false, # el8 only
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
}
