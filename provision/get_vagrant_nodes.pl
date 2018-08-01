#!/usr/bin/perl

use strict;
use warnings;
use Readonly;
use YAML::XS qw(LoadFile);

#------------------------------------------------------------------
# Definitions and variables
#------------------------------------------------------------------

# Our nodes definition
Readonly my $nodes_file => 'nodes.yaml';

# Which nodeset to use
Readonly my $nodeset => exists $ENV{'HIMLAR_NODESET'} ? $ENV{'HIMLAR_NODESET'} : 'default';

#==================================================================
# MAIN PROGRAM
#==================================================================

# Read in the nodes.yaml file
my $yaml = LoadFile($nodes_file);

# Output the nodes in the order they are defined in nodes.yaml
foreach my $ref (@{ $yaml->{nodesets}{$nodeset} }) {
    printf "%s%s\n", $ref->{role}, exists $ref->{hostid} ? "-$ref->{hostid}" : q{};
}
