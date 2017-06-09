#
class profile::openstack::network::calico(
  $manage_bird     = true,
  $manage_etcd     = true,
  $manage_firewall = true,
  $firewall_extras = {},
) {
  include ::calico

  if $manage_bird {
    include ::profile::network::bird
  }

  if $manage_etcd {
    include ::profile::application::etcd
  }

  # Define a wrapper to avoid duplicating config per interface
  # TODO: Make a proper define
  # lint:ignore:nested_classes_or_defines
  # lint:ignore:autoloader_layout
  define calico_interface {
  # lint:endignore
  # lint:endignore
    $iniface_name = regsubst($name, '_', '.')
    profile::firewall::rule { "010 bird bgp - accept tcp to ${name}":
        proto   => 'tcp',
        port    => '179',
        iniface => $iniface_name,
        extras  => $profile::openstack::network::calico::firewall_extras,
    }
    profile::firewall::rule { "010 bird bgp - accept tcp to ${name}-ipv6":
        proto    => 'tcp',
        port     => '179',
        iniface  => $iniface_name,
        extras   => $profile::openstack::network::calico::firewall_extras,
        provider => 'ip6tables',
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '910 dnsmasq - allow DHCP requests':
      proto  => 'udp',
      port   => ['67','68'],
      extras => {
        sport => ['67','68'],
      }
    }
    profile::firewall::rule { '912 bird allow bfd':
      proto  => 'udp',
      port   => ['3784','3785','4784','4785'],
    }
    # Per https://github.com/projectcalico/calico/blob/master/rpm/calico.spec#L43-L48
    profile::firewall::rule { '911 calico - mangle checksum for dhcp':
      proto => 'udp',
      chain => 'POSTROUTING',
      port  => '68',
      extras => {
        checksum_fill => true,
        table         => 'mangle',
        jump          => 'CHECKSUM',
        action        => undef,
        state         => undef,
      },
    }

    # Depend on $::service_interfaces and $::transport_interfaces fact
    # - on master, $::service_interfaces will return an array with a single if
    # - on compute, $::transport_interfaces will return one or two ifs
#    if is_array($::service_interfaces) {
#      calico_interface { $::service_interfaces: }
#    }
    if is_array($::transport_interfaces) {
      calico_interface { $::transport_interfaces: }
    }
  }
}
