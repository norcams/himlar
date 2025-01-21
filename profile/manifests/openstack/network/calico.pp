#
class profile::openstack::network::calico(
  $manage_bird               = true,
  $manage_etcd               = false,
  $manage_etcd_grpc_proxy    = false,
  $packagename_etcdgw        = python3-etcd3gw,
  $manage_firewall           = true,
  $manage_firewall6          = false,
  $manage_dhcp_agent         = false,
  $firewall_extras           = {},
) {
  include ::calico

  if $manage_bird {
    include ::profile::network::bird
  }

  if $manage_etcd {
    include ::profile::application::etcd
  }

  if $manage_etcd_grpc_proxy {
#    package { 'etcd':              # FIXME: sooner or later computes wont have etcd v2 proxy
#      ensure => installed,
#    }
    package { $packagename_etcdgw:
      ensure => installed,
    } ~>
    file { "etcd_grpc_proxy":
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0644',
      path     => "/etc/systemd/system/etcd-grpc-proxy.service",
      content  => template("${module_name}/network/etcd_grpc_proxy_service.erb"),
    } ~>
    service { 'etcd-grpc-proxy.service':
      ensure      => running,
      enable      => true,
      hasrestart  => true,
      hasstatus   => true,
    }
  }

  # Override ownership of the calico-dhcp-agent process as it should not be root
  # If calico-dhcp-agent was spawned as root, we must ensure correct permissions
  if $manage_dhcp_agent {
    file { 'calico-dhcp-agent-dir':
      ensure  => directory,
      path    => "/etc/systemd/system/calico-dhcp-agent.service.d",
      owner   => root,
      group   => root,
    }
    file { 'dhcp-agent-override':
      ensure  => file,
      path    => '/etc/systemd/system/calico-dhcp-agent.service.d/override.conf',
      owner   => root,
      group   => root,
      content => "[Service]\nUser=neutron\nExecStartPost=+/usr/local/bin/calico_iplink_helper.sh\n",
      notify  => Service['calico-dhcp-agent']
    }
    file { 'calico_iplink_helper.sh':
      ensure  => file,
      path    => '/usr/local/bin/calico_iplink_helper.sh',
      content => template("${module_name}/openstack/network/calico_iplink_helper.sh.erb"),
      mode    => '0755',
    }
    file { 'neutron-log-perms':
      ensure  => directory,
      path    => "/var/log/neutron/",
      owner   => neutron,
      group   => neutron,
      recurse => true,
      notify  => Service['calico-dhcp-agent']
    }
    file { 'neutron-workdir-perms':
      ensure  => directory,
      path    => "/var/lib/neutron/dhcp/",
      owner   => neutron,
      group   => neutron,
      recurse => true,
      notify  => Service['calico-felix']
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '910 dnsmasq - allow DHCP requests':
      proto  => 'udp',
      dport  => ['67','68'],
      extras => {
        sport => ['67','68'],
      }
    }
    profile::firewall::rule { '011 bird allow bfd':
      proto  => 'udp',
      dport  => ['3784','3785','4784','4785'],
    }
    # Per https://github.com/projectcalico/calico/blob/master/rpm/calico.spec#L43-L48
    profile::firewall::rule { '911 calico - mangle checksum for dhcp':
      proto => 'udp',
      chain => 'POSTROUTING',
      dport  => '68',
      extras => {
        checksum_fill => true,
        table         => 'mangle',
        jump          => 'CHECKSUM',
        action        => undef,
        state         => undef,
      },
    }
    if $manage_firewall6 {
      profile::firewall::rule { '011 bird allow bfd ipv6':
        proto    => 'udp',
        port     => ['3784','3785','4784','4785'],
        provider => 'ip6tables',
      }
      profile::firewall::rule { "010 bgp ipv6 - accept tcp to ${name}":
        proto    => 'tcp',
        port     => '179',
        provider => 'ip6tables',
        iniface  => $::ipaddress6_trp1,
      }
    }

    # Depend on $::service_interfaces and $::transport_interfaces fact
    # - on master, $::service_interfaces will return an array with a single if
    # - on compute, $::transport_interfaces will return one or two ifs
#    if is_array($::service_interfaces) {
#      profile::openstack::network::calico::calico_interface { $::service_interfaces: }
#    }
    if is_array($::transport_interfaces) {
      profile::openstack::network::calico::calico_interface { $::transport_interfaces: }
    }
  }
}
