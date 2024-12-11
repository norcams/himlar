#
# For el7 http proxy is managed by the profile::base::network class
#
class profile::base::httpproxy(
  $manage_httpproxy   = false,
  $http_proxy         = undef,
  $https_proxy        = undef,
  $http_proxy_profile = '/etc/profile.d/proxy.sh',
) {

  if $manage_httpproxy {
    $ensure_value = $http_proxy ? {
      undef   => absent,
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
}
