# Use /etc/hosts for a simple local DNS in development/vagrant
class profile::development::network::dns(
  $manage_hosts = false,
  $use_dnsmasq = false,
  $remove_local_hostname = false,
  $dns_merge_strategy = $profile::network::services::dns_merge_strategy
) {

  if $manage_hosts {
    # Fetch dns records
    $dns = lookup('profile::network::services::dns_records', Hash, $dns_merge_strategy, {})
    # Create temp variable
    $list = join_keys_to_values($dns['A'], '|')
    # Update /etc/hosts
    profile::development::network::dns_record { $list:
      use_dnsmasq => $use_dnsmasq
    }
  }

  if $remove_local_hostname {
    # this will fix problems in vagrant for services running on fqdn in mgmt
    file_line { 'remove-localhost-hostrecord':
      ensure            => absent,
      path              => '/etc/hosts',
      match             => "^127.0.1.1 ${::fqdn}",
      match_for_absence => true,
    }
  }
}
