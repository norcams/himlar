# Assuming trusted_node_data = true in puppet.conf
# https://docs.puppetlabs.com/puppet/3/reference/lang_variables.html#trusted-node-data
# 
# We expect a certain certname format, e.g
#  * role-location-identifier.domain.com
#  * haproxy-bgo-01.snakeoil.int
#
# Parse data from $trusted['certname'] for hiera lookup
$verified_certname = $trusted['certname']
$certname_a        = split($verified_certname, "-")
$location          = $::certname_a[0]
$role              = $::certname_a[1]

hiera_include('classes', [])

# Empty default node
node default { }

