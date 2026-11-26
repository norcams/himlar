# Node side of the software RAID health check.
#
# This installs the check script. The check itself is defined on the sensu
# backend, see the 'mdraid-check' entry in
# profile::monitoring::sensu::agent::checks, and is only run on agents that
# subscribe to 'mdraid'.
#
# Independent of profile::base::mdadm on purpose. Plenty of arrays are built
# by the installer and never touched by puppet, the root disk mirror above
# all, and those need watching just as much as the ones we create. So:
#
#   - where puppet manages the arrays, this follows
#     profile::base::common::manage_mdadm and needs no extra hiera
#   - where the array came from kickstart, set enable on its own:
#
#       profile::monitoring::mdraid::enable: true
#
#   - setting enable explicitly always wins, either way, so a host with
#     managed arrays can still opt out
#
# The subscription is separate and has to be set on the host or role as well,
# the same two-part setup as profile::monitoring::smart:
#
#   sensu::agent::subscriptions:
#     - 'base'
#     - 'metrics'
#     - 'physical'
#     - 'mdraid'
#
# Both are needed. The subscription on its own makes the backend run the check
# on a node where the script was never installed.
#
# The script reads /proc/mdstat only, so unlike profile::monitoring::smart it
# needs no package and no sudo rule, and it is just as happy on a VM as on
# iron. A host with no arrays at all reports OK rather than failing, so
# turning this on ahead of the disks is harmless.
#
class profile::monitoring::mdraid (
  Optional[Boolean] $enable      = undef,
  String            $script_path = '/usr/local/bin/check_mdraid.sh',
) {

  $_enable = $enable ? {
    undef   => lookup('profile::base::common::manage_mdadm', Boolean, 'first', false),
    default => $enable,
  }

  if $_enable and ($::runmode == 'default') {
    file { $script_path:
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => "puppet:///modules/${module_name}/monitoring/sensugo/checks/check_mdraid.sh",
    }
  }
}
