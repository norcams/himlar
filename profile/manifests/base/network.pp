#
class profile::base::network(
  $manage_dummy     = false,
  $no_of_dummies    = 1,
  $manage_httpproxy = false,
  $http_proxy       = undef,
  $remove_route     = false,
  $remove_route_ifs = undef,
  $l3_router        = false,
) {

  # Set up extra logical fact names for network facts
  include ::named_interfaces

  # example42 network module
  include ::network

  # - Set ifnames=0 and use old ifnames, e.g 'eth0'
  # - Use biosdevname on physical servers, e.g 'em1'
  kernel_parameter { "net.ifnames":
    ensure => present,
    value  => "0",
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

  # Create extra routes on ifup
  create_resources(network::mroute, hiera_hash('profile::base::network::mroute', {}))

  if $manage_httpproxy {
    $ensure_value = $http_proxy ? {
      undef    => absent,
      default => present,
    }
    $target = "/etc/profile.d/proxy.sh"

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
}
