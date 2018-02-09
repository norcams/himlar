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
# == Class: profile::firewall::pre
#
class profile::firewall::pre(
  $established_settings = {},
  $icmp_settings        = {},
  $ipv6_icmp_settings   = {},
  $loopback_settings    = {},
  $ssh_settings         = {},
  $ipv6_ssh_settings    = {},
  $manage_ipv6_ssh      = false,
  $manage_ssh           = true,
){

  # ensure the correct packages are installed
  include firewall

  # defaults 'pre' rules
  profile::firewall::rule{ '000 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    extras => $established_settings,
  }

  profile::firewall::rule{ '001 accept all icmp':
    proto  => 'icmp',
    extras => $icmp_settings,
  }

  profile::firewall::rule{ '002 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    extras  => $loopback_settings,
  }

  if $manage_ssh {
    profile::firewall::rule{ '003 accept ssh':
      dport  => '22',
      extras => $ssh_settings,
    }
  }

  if $manage_ipv6_ssh {
    profile::firewall::rule{ '003 ipv6 accept ssh':
      dport    => '22',
      extras   => $ipv6_ssh_settings,
      provider => 'ip6tables',
    }
  }

  # defaults 'pre' rules
  profile::firewall::rule{ '000 ipv6 accept related established rules':
    proto    => 'all',
    state    => ['RELATED', 'ESTABLISHED'],
    extras   => $established_settings,
    provider => 'ip6tables',
  }

  profile::firewall::rule{ '001 ipv6 accept all icmp':
    proto    => 'ipv6-icmp',
    extras   => $ipv6_icmp_settings,
    provider => 'ip6tables',
  }

  profile::firewall::rule{ '002 ipv6 accept all to lo interface':
    proto    => 'all',
    iniface  => 'lo',
    extras   => $loopback_settings,
    provider => 'ip6tables',
  }
}
