#
# bios.rb
#
# This fact provides more details about the system BIOS
# taken from the DMI (Direct Media Interface) space.
#

require 'facter/manufacturer'

query = {
  'BIOS [Ii]nformation' => [
    { 'Vendor:'           => 'bios_vendor'            },
    { 'Version:'          => 'bios_version'           },
    { 'Release Date:'     => 'bios_release_date'      },
    { 'ROM Size:'         => 'bios_rom_size'          },
    { 'BIOS Revision:'    => 'bios_revision'          },
    { 'Firmware Revision' => 'bios_firmware_revision' }
  ]
}

# We call existing helper function to do the heavy-lifting ...
Facter::Manufacturer.dmi_find_system_info(query)

# vim: set ts=2 sw=2 et :
# encoding: utf-8
