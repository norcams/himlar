# Tell the operating system that the passed hash with devices are
# are non-rotational (i.e ssd drives)
define profile::storage::fake_ssd (
) {
  exec { "set_fake_ssd-${name}":
    command => "/bin/echo '0' > /sys/block/${name}/queue/rotational",
    unless  => "/bin/cat /sys/block/${name}/queue/rotational | grep 0 >/dev/null 2>&1",
  }
}
