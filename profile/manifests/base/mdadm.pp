# Software RAID (mdadm), the md counterpart to profile::base::lvm.
#
# el9 and newer only. Paths and unit names are hardcoded for it, no osfamily
# branching, so do not turn this on elsewhere without revisiting them.
#
# Off everywhere by default. Enable per host, or per role once the disk layout
# is settled:
#
#   profile::base::common::manage_mdadm: true
#   profile::base::mdadm::array:
#     '/dev/md/instances':
#       level: '1'
#       devices:
#         - '/dev/disk/by-id/wwn-0x55cd2e41508e56dd-part4'
#         - '/dev/disk/by-id/wwn-0x55cd2e41508e5701-part4'
#
# An md array is normally the physical volume below LVM. profile::base::common
# orders this class before profile::base::lvm, so the same host goes on with
# the usual lvm hiera, pointing at the array instead of a bare partition:
#
#   profile::base::lvm::physical_volume:
#     '/dev/md/instances':
#       ensure: present
#   profile::base::lvm::volume_group:
#     'vg_ext':
#       followsymlinks: true
#       physical_volumes:
#         - '/dev/md/instances'
#
# Use /dev/disk/by-id/wwn-* for the members, the same as we do for lvm on the
# newer computes. Kernel names are not stable across reboots and an array
# assembled from the wrong sd* is a bad day.
#
# Creation is deliberately one-shot and conservative, see
# profile::base::mdadm::array for what is and is not touched on later runs.
#
# The arrays are built in the kickstart run, the same as lvm. Anaconda only
# ever touches the install device, everything else on the host is ours, and
# the foreman kickstart does a full catalog apply from inside the %post chroot
# ('run-puppet-in-installer' is a global parameter). Building the array there
# is what lets profile::base::lvm put vg_ext on top of it in the same run, so
# the host comes out of provisioning with /var/lib/nova/instances mounted
# rather than with a failed pv and a second run to fix it.
#
# The service and the initramfs rebuild are the exceptions and stay out of
# kickstart. In the installer chroot systemctl talks to the installer's
# systemd, which knows nothing of the units under /mnt/sysimage, and dracut
# would build against the anaconda kernel rather than the installed one.
# Neither is needed before the first boot.
#
# Alerting is sensu, through profile::monitoring::mdraid. That class is kept
# independent of this one, since an array built by the installer needs
# watching whether or not puppet manages it. It does default to on wherever
# manage_mdadm is set, so enabling this class is normally enough. Adding
# 'mdraid' to sensu::agent::subscriptions is the other half, see that class.
#
# mailaddr is left unset on purpose. The mdmonitor service still runs and
# still reports every event, to syslog, which we ship anyway. Set it only if
# mail to root is wanted as a second route on top of sensu.
#
class profile::base::mdadm (
  Boolean          $create_arrays     = true,
  Boolean          $manage_package    = true,
  Boolean          $manage_conf       = true,
  Boolean          $manage_service    = true,
  Boolean          $manage_raid_check = false,
  Boolean          $update_initramfs  = false,
  String           $package_name      = 'mdadm',
  String           $service_name      = 'mdmonitor',
  String           $conf_file         = '/etc/mdadm.conf',
  Optional[String] $mailaddr          = undef,
  Hash             $raid_check_options = {},
) {

  if $manage_package {
    package { $package_name:
      ensure => present,
    }
  }

  if $manage_conf {
    # Content is not managed, only appended to. The ARRAY lines come from
    # 'mdadm --detail --brief' as each array is created, MAILADDR from here.
    file { $conf_file:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    if $mailaddr {
      file_line { 'mdadm.conf mailaddr':
        path  => $conf_file,
        line  => "MAILADDR ${mailaddr}",
        match => '^MAILADDR',
      }
    }
  }

  if $create_arrays {
    $arrays = lookup('profile::base::mdadm::array', Hash, 'first', {})

    create_resources('profile::base::mdadm::array', $arrays, {
      'conf_file'   => $conf_file,
      'manage_conf' => $manage_conf,
    })
  }

  # What is left needs a systemd that owns the root we are installing to, or a
  # running kernel that matches it, so it waits for the first real boot
  if $::runmode != 'kickstart' {

    # Only needed when the root filesystem sits on an array, off by default
    if $update_initramfs {
      exec { 'mdadm-update-initramfs':
        command     => 'dracut --force',
        path        => '/usr/bin:/usr/sbin:/bin:/sbin',
        refreshonly => true,
      }

      Profile::Base::Mdadm::Array <| |> ~> Exec['mdadm-update-initramfs']
    }

    # The el9 unit runs 'mdadm --monitor --scan --syslog', and --syslog counts
    # as an alert destination, so this starts and monitors with no MAILADDR
    # set and reports events to syslog instead. Set mailaddr only if mail is
    # wanted on top of the sensu check.
    #
    # The unit also carries ConditionPathExists=/etc/mdadm.conf. Systemd skips
    # it without a word if the file is missing, 'systemctl start' still exits
    # 0, and puppet then reports a change here on every run without ever
    # getting there. manage_conf creates the file, so leave it on whenever the
    # service is managed.
    if $manage_service {
      service { $service_name:
        ensure => running,
        enable => true,
      }
    }

    # 'raid-check' is the weekly consistency scrub shipped with the mdadm
    # package, driven by raid-check.timer
    if $manage_raid_check {
      $raid_check_options.each |$key, $value| {
        file_line { "raid-check ${key}":
          path  => '/etc/sysconfig/raid-check',
          line  => "${key}=${value}",
          match => "^${key}=",
        }
      }

      service { 'raid-check.timer':
        ensure => running,
        enable => true,
      }
    }
  }

  # Order: package, then the conf file the arrays append their ARRAY lines to,
  # then the arrays, then the service that reads the conf
  if $manage_package {
    Package[$package_name] -> Profile::Base::Mdadm::Array <| |>
  }

  if $manage_conf {
    File[$conf_file] -> Profile::Base::Mdadm::Array <| |>
  }

  if ($::runmode != 'kickstart') and $manage_service {
    if $manage_package {
      Package[$package_name] -> Service[$service_name]
    }
    if $manage_conf {
      File[$conf_file] -> Service[$service_name]
    }
    Profile::Base::Mdadm::Array <| |> -> Service[$service_name]
  }
}
