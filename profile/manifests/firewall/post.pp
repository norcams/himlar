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
class profile::firewall::post(
  $debug             = false,
  $log               = false,
  $firewall_settings = {},
){

  if $log {
    firewall { '998 log all':
      proto => 'all',
      jump  => 'LOG',
    }
    firewall { '998 ipv6 log all':
      proto => 'all',
      jump  => 'LOG',
      provider => 'ip6tables',
    }
  }

  if $debug {
    # purge all non-managed rules
    resources { 'firewall':
      purge => true
    }
    warning('debug enabled, purging all non-managed rules')
    warning('debug enabled, NO TRAFFIC IS BLOCKED.')
  } else {
    profile::firewall::rule{ '999 drop all':
      proto  => 'all',
      action => 'drop',
      extras => $firewall_settings,
    }
    notice('At this stage, all network traffic is blocked.')
  }

  if $debug {
    # purge all non-managed rules
    resources { 'firewall':
      purge    => true,
      provider => 'ip6tables',
    }
    warning('debug enabled, purging all ipv6 non-managed rules')
    warning('debug enabled, NO IPv6 TRAFFIC IS BLOCKED.')
  } else {
    profile::firewall::rule{ '999 ipv6 drop all':
      proto    => 'all',
      action   => 'drop',
      extras   => $firewall_settings,
      provider => 'ip6tables',
    }
    notice('At this stage, all network traffic is blocked.')
  }
}
