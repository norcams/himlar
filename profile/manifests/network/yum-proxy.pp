#
class profile::network::yum-proxy(
  $yum_proxy    = "",
) {

  if($yum_proxy != "")  {
    file_line { 'yum_proxy':
      path    => '/etc/yum.conf',
      line    => "proxy=$yum_proxy",
      match   => "^proxy=",
    }
  }
}

