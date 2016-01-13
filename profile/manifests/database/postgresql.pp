#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/concat'
#   mod 'puppetlabs/apt'
#   mod 'yguenane/postgresqlrepo'
#   mod 'puppetlabs/postgresql'
#
class profile::database::postgresql (
  $contrib_enable  = true,
  $devel_enable    = false,
  $postgis_enable  = false,
  $java_enable     = false,
  $perl_enable     = false,
  $python_enable   = false,
  $plperl_enable   = false,
  $config_entries  = {},
  $dbs             = {},
  $databases       = {},
  $database_grants = {},
  $pg_hba_rules    = {},
  $roles           = {},
  $table_grants    = {},
  $tablespaces     = {},
) {

  include ::postgresqlrepo
  include ::postgresql::globals
  include ::postgresql::server

  if $contrib_enable {
    include ::postgresql::server::contrib
  }

  if $devel_enable {
    include ::postgresql::server::devel
  }

  if $postgis_enable {
    include ::postgresql::server::postgis
  }

  if $plperl_enable {
    include ::postgresql::server::plperl
  }

  if $perl_enable {
    include ::postgresql::lib::perl
  }

  if $java_enable {
    include ::postgresql::lib::java
  }

  if $python_enable {
    include ::postgresql::lib::python
  }

  create_resources('postgresql::server::config_entry', $config_entries)
  create_resources('postgresql::server::db', $dbs)
  create_resources('postgresql::server::database', $databases)
  create_resources('postgresql::server::database_grant', $database_grants)
  create_resources('postgresql::server::pg_hba_rule', $pg_hba_rules)
  create_resources('postgresql::server::role', $roles)
  create_resources('postgresql::server::table_grant', $table_grants)
  create_resources('postgresql::server::tablespace', $tablespaces)

}
