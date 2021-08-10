# Define: profile::base::hdparm
#
# hdparams can be one or more options to hdparm for a single device,
# for example "-W0" to disable write cache
#
# the device name is expected to include the full /dev path
#
define profile::base::hdparm (
  $ensure     = present,
  $hdparams   = undef,
  $order      = 69,
  $hdparmpath = '/sbin/hdparm'
) {

  $devicename = split($name, '/' )[-1]

  file { "hdparm_${name}":
    ensure    => file,
    path      => "/etc/udev/rules.d/${order}-hdparm-${devicename}.rules",
    content   => "ACTION==\"add\", SUBSYSTEM==\"block\", KERNEL==\"${devicename}\", RUN+=\"${hdparmpath} ${hdparams} ${name}\"\n",
  }
}
