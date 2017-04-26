#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
define profile::firewall::rule (
  $port        = undef,
  $dport       = undef,
  $proto       = 'tcp',
  $action      = 'accept',
  $state       = ['NEW'],
  $source      = '0.0.0.0/0',
  $destination = undef,
  $iniface     = undef,
  $chain       = 'INPUT',
  $provider    = 'iptables',
  $extras      = {},
) {

  if $port { # port is depricated. Use dport. FIXME report $port
    warning('NORCAMS: Use of $port in firewall rules are depricated! Use $dport.')
    $basic = {
      'dport'       => $port,
      'proto'       => $proto,
      'action'      => $action,
      'state'       => $state,
      'source'      => $source,
      'destination' => $destination,
      'iniface'     => $iniface,
      'chain'       => $chain,
      'provider'    => $provider
    }
  } else {
    $basic = {
      'dport'       => $dport,
      'proto'       => $proto,
      'action'      => $action,
      'state'       => $state,
      'source'      => $source,
      'destination' => $destination,
      'iniface'     => $iniface,
      'chain'       => $chain,
      'provider'    => $provider
    }

  }
  $rule = merge($basic, $extras)
  validate_hash($rule)

  # We can only expand source or destination, not both!
  if is_array($source) {
    profile::firewall::expand_rule { $source:
      rule      => $rule,
      type      => 'source',
      rule_name => $name
    }
  } elsif is_array($destination) {
    profile::firewall::expand_rule { $destination:
      rule      => $rule,
      type      => 'destination',
      rule_name => $name
    }
  } else {
    create_resources('firewall', { "${title}" => $rule })
  }

}
