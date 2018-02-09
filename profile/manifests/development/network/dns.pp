# Use /etc/hosts for a simple local DNS in development/vagrant
class profile::development::network::dns(
  $manage_hosts = false,
  $use_dnsmasq = false
) {

  if $manage_hosts {
    # Fetch dns records
    $dns = lookup('profile::network::services::dns_records', Hash, 'deep', {})
    # Create temp variable
    $list = join_keys_to_values($dns['A'], '|')
    # Update /etc/hosts
    profile::development::network::dns_record { $list:
      use_dnsmasq => $use_dnsmasq
    }
  }

}
