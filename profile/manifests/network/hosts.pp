class profile::network::hosts(
) {
  create_resources( host, lookup('profile::network::hosts::records', Hash, 'deep', {}))
}

