# Assuming trusted_node_data = true in puppet.conf
# https://docs.puppetlabs.com/puppet/3/reference/lang_variables.html#trusted-node-data
#
# We expect a certain certname format, e.g
#  * location-role-identifier.domain.com
#  * bgo-haproxy-01.snakeoil.internal
#
# Parse data from $trusted['certname'] for hiera lookup
$verified_certname = $::trusted['certname']
$dot_a             = split($::verified_certname, '\.')
$verified_host     = $dot_a[0]
$dash_a            = split($::verified_host, '-')

$location          = $::dash_a[0]
$role              = $::dash_a[1]
if size($dash_a) == 4 {
  $variant = $::dash_a[2]
  $hostid  = $::dash_a[3]
} else {
  $hostid  = $::dash_a[2]
  $variant = ''
}

# Needed to debug module load order
#info("DEBUG:modulepath=${settings::modulepath}")

# Determine OS and major OS version
case $::osfamily {
  'RedHat': {
    $os_platform = 'el'
    $os_version  = $::operatingsystemmajrelease
    }
  'Debian': {
    if $variant == 'opx' {
      $os_platform = $variant
      $os_version  = '3'
    } else {
      $os_platform = downcase(regsubst($::operatingsystem, 'Linux', ''))
      $os_version  = regsubst($::operatingsystemmajrelease, '\.', '')
    }
  }
  default: {
    $os_platform = 'unknown'
    $os_version  = '1'
  }
}

if fact('network_mgmt1') {
  $netpart_mgmt1 = regsubst($network_mgmt1,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\1.\2.\3')
  info("netpart_mgmt1: ${netpart_mgmt1}")
}
if fact('network_transport1') {
  $netpart_transport1 = regsubst($network_transport1,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\1.\2.\3')
  info("netpart_transport1: ${netpart_transport1}")
}
if fact('network_trp1') {
  $netpart_trp1 = regsubst($network_trp1,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\1.\2.\3')
  info("netpart_trp1: ${netpart_trp1}")
}

# Set runmode to default if it is not provided
unless fact('runmode') {
  if fact('is_installer') { # from kickstart in foreman
    $runmode = 'kickstart'
  } else {
    $runmode='default'
  }
}

# BMC variables (only run on physical machines and not on kickstart run)
unless $::is_virtual == true or $runmode == 'kickstart'  {
  $bmc_network  = Integer(regsubst($::ipaddress_mgmt1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\2',)) + 1
  $bmc_address  = regsubst($::ipaddress_mgmt1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$',"\\1.${bmc_network}.\\3.\\4",)
}

#info("platform=${os_platform}")
#info("version=${os_version}")

# Query for hash of classes to include
$runmode_classes = lookup("include.${::runmode}", Array, 'deep', [])
$runmode_classes.include

# Output the node classification data
info("certname=${verified_certname} env=${environment} location=${location} role=${role} hostid=${hostid} runmode=${::runmode}")
info(join($runmode_classes,' '))

# Empty default node
node default { }
