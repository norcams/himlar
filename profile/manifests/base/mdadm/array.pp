# One md array. Declared from hiera through profile::base::mdadm, see that
# class for the full picture.
#
# The title is the array device, either a kernel name or a named array:
#
#   profile::base::mdadm::array:
#     '/dev/md/instances':
#       level: '1'
#       devices:
#         - '/dev/disk/by-id/wwn-0x55cd2e41508e56dd-part4'
#         - '/dev/disk/by-id/wwn-0x55cd2e41508e5701-part4'
#
#     '/dev/md/scratch':
#       level:         '10'
#       layout:        'n2'
#       chunk:         '512'
#       spare_devices: 1
#       devices:
#         - '/dev/disk/by-id/wwn-0x...-part1'
#         - ... five more, four active plus one spare
#
# What happens on a run, in order:
#
#   1. If the array is not running but its members carry an md superblock, it
#      is assembled. This is the reboot and reinstall path.
#   2. If the array is not running and no member carries a superblock, it is
#      created. This is the one and only time we write a new array.
#   3. Its ARRAY line is appended to mdadm.conf, matched on the array UUID so
#      a renamed device does not give us a duplicate entry.
#
# The create guard is the important one. An array is never created over
# members that already hold md metadata, so a re-run, a reinstall with the
# disks kept, or a wrong device in hiera cannot wipe live data. It also means
# we do not reshape: changing level, chunk or the device list of an existing
# array does nothing here, do that by hand and update hiera to match.
#
# A missing member device never fails the run. Creation is skipped entirely,
# assembly goes ahead with what is there and brings the array up degraded, and
# the mdraid check is what tells us about it. A dead disk should page us, not
# block the rest of the catalog.
#
define profile::base::mdadm::array (
  Array[String[1]]             $devices,
  Variant[Integer, String[1]]  $level,
  Enum['present', 'absent'] $ensure            = 'present',
  Boolean                      $manage        = true,
  String[1]                    $device        = $name,
  Optional[Integer]            $raid_devices  = undef,
  Optional[Integer]            $spare_devices = undef,
  Optional[String[1]]          $chunk         = undef,
  Optional[String[1]]          $layout        = undef,
  Optional[String[1]]          $array_name    = undef,
  Optional[String[1]]          $bitmap        = undef,
  String[1]                    $metadata      = '1.2',
  Boolean                      $force         = false,
  Boolean                      $manage_conf   = true,
  String[1]                    $conf_file     = '/etc/mdadm.conf',
) {

  if $manage {
    $path       = '/usr/bin:/usr/sbin:/bin:/sbin'
    $member_str = join($devices, ' ')

    # True when at least one member already holds md metadata, ie the array
    # exists on disk even if it is not currently assembled
    $has_superblock = join($devices.map |$dev| { "mdadm --examine ${dev} > /dev/null 2>&1" }, ' || ')

    # True when every member is present as a block device
    $members_present = join($devices.map |$dev| { "test -b ${dev}" }, ' && ')

    # True when the array is assembled and running
    $is_running = "mdadm --detail ${device} > /dev/null 2>&1"

    case $ensure {
      'present': {
        $_spares = $spare_devices ? {
          undef   => 0,
          default => $spare_devices,
        }
        $_actives = $raid_devices ? {
          undef   => length($devices) - $_spares,
          default => $raid_devices,
        }

        $opt_spares = $_spares ? {
          0       => '',
          default => " --spare-devices=${_spares}",
        }
        $opt_chunk = $chunk ? {
          undef   => '',
          default => " --chunk=${chunk}",
        }
        $opt_layout = $layout ? {
          undef   => '',
          default => " --layout=${layout}",
        }
        $opt_bitmap = $bitmap ? {
          undef   => '',
          default => " --bitmap=${bitmap}",
        }
        $opt_name = $array_name ? {
          undef   => '',
          default => " --name=${array_name}",
        }
        $opt_force = $force ? {
          true    => ' --force',
          default => '',
        }

        # --run answers the 'Continue creating array?' prompt, without it
        # mdadm blocks forever on a puppet run
        $create_cmd = join([
          "mdadm --create ${device} --run${opt_force}",
          "--level=${level} --raid-devices=${_actives}${opt_spares}",
          "--metadata=${metadata}${opt_chunk}${opt_layout}${opt_bitmap}${opt_name}",
          $member_str,
        ], ' ')

        # Assemble first, so the create guard below sees a running array.
        # Deliberately not gated on every member being present, and --run so
        # an array that lost a disk still comes up degraded rather than not
        # at all.
        exec { "mdadm-assemble-${device}":
          command  => "mdadm --assemble --run ${device} ${member_str}",
          path     => $path,
          provider => shell,
          onlyif   => $has_superblock,
          unless   => $is_running,
        }

        exec { "mdadm-create-${device}":
          command  => $create_cmd,
          path     => $path,
          provider => shell,
          onlyif   => $members_present,
          unless   => "${is_running} || ${has_superblock}",
          require  => Exec["mdadm-assemble-${device}"],
        }

        if $manage_conf {
          # Match on the UUID rather than the device name. mdadm --detail
          # --brief prints whatever name the array was created with, which is
          # not always the title we were given here.
          #
          # The first grep is not redundant: 'grep -qFf -' with an empty
          # pattern list matches everything and returns 0, so without it a
          # lookup that came back empty would look like 'already in the file'
          # and we would never write the ARRAY line.
          $brief = "mdadm --detail --brief ${device}"
          $uuid  = "${brief} | grep -oE 'UUID=[^[:space:]]+'"

          exec { "mdadm-conf-${device}":
            command  => "${brief} >> ${conf_file}",
            path     => $path,
            provider => shell,
            onlyif   => $is_running,
            unless   => "${uuid} | grep -q . && ${uuid} | grep -qFf - ${conf_file}",
            require  => Exec["mdadm-create-${device}"],
          }
        }
      }

      # Destroys the array and the md metadata on its members. Nothing guards
      # this beyond having written it in hiera, so be sure.
      #
      # There is no 'stopped' on purpose. Stopping without zeroing does not
      # stick, 64-md-raid-assembly.rules runs 'mdadm --incremental' on every
      # block device event and puts the array straight back, so puppet would
      # stop it again on the next run forever. It also fails outright while
      # the array is a mounted filesystem or an lvm pv, which is what we build
      # these for. To hand an array back to manual control, drop it from hiera
      # and it keeps running untouched.
      'absent': {
        exec { "mdadm-stop-${device}":
          command  => "mdadm --stop ${device}",
          path     => $path,
          provider => shell,
          onlyif   => $is_running,
        }

        exec { "mdadm-zero-${device}":
          command  => "mdadm --zero-superblock ${member_str}",
          path     => $path,
          provider => shell,
          onlyif   => "${members_present} && ( ${has_superblock} )",
          require  => Exec["mdadm-stop-${device}"],
        }

        if $manage_conf {
          # Matched on the device, not the UUID as above, since there is no
          # array left to ask. An ARRAY line written under a different name
          # has to be removed by hand.
          file_line { "mdadm.conf remove ${device}":
            ensure            => absent,
            path              => $conf_file,
            match             => "^ARRAY[[:space:]]+${device}([[:space:]]|\$)",
            match_for_absence => true,
          }
        }
      }

      default: {
        fail("Unsupported ensure '${ensure}' for profile::base::mdadm::array")
      }
    }
  }
}
