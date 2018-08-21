#!/usr/bin/python
#
# This script will remove all traces of tap interfaces from a compute host's
# fact file. Run in a cronjob before node.rb --push-facts
#
# Done in a hurry, code quality may vary :)
#
# Depends on python2-ruamel-yaml

from collections import MutableMapping
import fcntl
import os
import sys
import ruamel.yaml

matched_keys = []
facts_dict = {}

def find_keys(my_dict, string):
    for key, value in my_dict.iteritems():
        if isinstance(value, MutableMapping):
            for k, v in value.iteritems():
                if string in k:
                    matched_keys.append(k)
            find_keys(value, string)
        else:
            if string in key:
                matched_keys.append(key)

def delete_keys_from_dict(dictionary, keys):
    for key in keys:
        try:
            del dictionary[key]
        except KeyError:
            pass
    for value in dictionary.values():
        if isinstance(value, MutableMapping):
            delete_keys_from_dict(value, keys)

def parse_files(path):
    facts_files = []
    for f in os.listdir(path):
        if 'compute' in f:
            full_path = os.path.join(path, f)
            if os.path.isfile(full_path):
                facts_files.append(full_path)
    for facts_file in facts_files:
        filename = facts_file
        with open(facts_file, 'r') as yaml_facts:
            fcntl.flock(yaml_facts, fcntl.LOCK_EX | fcntl.LOCK_NB)
            if os.stat(facts_file).st_size != 0:
                try:
                    parsed = ruamel.yaml.round_trip_load(yaml_facts,
                                                         preserve_quotes=True)
                except:
                    print "WARNING: Couldn't parse %s" % facts_file
                    fcntl.flock(yaml_facts, fcntl.LOCK_UN)
                facts_dict[filename] = parsed
            else:
                print "WARNING: %s is empty" % facts_file
                fcntl.flock(yaml_facts, fcntl.LOCK_UN)

facts_path = '/opt/puppetlabs/server/data/puppetserver/yaml/facts'
parse_files(facts_path)

for filename, facts in facts_dict.iteritems():
    find_keys(facts, 'tap')
    delete_keys_from_dict(facts, matched_keys)

    interface_list = facts['values']['interfaces'].split(',')
    tap_if = []

    for interface in interface_list:
        if 'tap' in interface:
            tap_if.append(interface)

    for interface in tap_if:
        interface_list.remove(interface)

    facts['values']['interfaces'] = ','.join(interface_list)

    with open(filename, 'w') as outfile:
        fcntl.flock(outfile, fcntl.LOCK_UN)
        try:
            ruamel.yaml.round_trip_dump(facts, outfile, explicit_start=True)
        except:
            print "WARNING: Couldn't write to %s" % filename
