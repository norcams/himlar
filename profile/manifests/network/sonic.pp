# custom profile for sonic switches
class profile::network::sonic(
  Boolean $enable_scripts = false,
) {

  # enable custom sonic script to take down and up endpoint ports etc
  if $enable_scripts {
    include ::network::config_db::scripts
  }

}
