#!/usr/bin/perl

use strict;
use warnings;
use Readonly;
use File::Find;
use Config::IniFiles;
use YAML::XS qw(LoadFile);
use Getopt::Long qw(:config no_ignore_case);

# Usage info
Readonly my $USAGE => <<"END_USAGE";
Usage: $0 [OPTION...] <dir1> <dir2>
END_USAGE

# Help output
Readonly my $HELP => <<'END_HELP';

OPTIONS:
  -h, --help               Print help information

END_HELP

# Options with default values
my %opt
  = (
     'help' => 0,
    );

# Get options
GetOptions('h|help' => \$opt{help},
          ) or do { print $USAGE; exit 1 };

# If user requested help
if ($opt{help}) {
    print $USAGE, $HELP;
    exit 0;
}

# Get directories
my $dir1 = $ARGV[0];
my $dir2 = $ARGV[1];

# Handle errors
if (!defined $dir1 or !defined $dir2) {
    print $USAGE, $HELP;
    exit 1;
}
if (! -e $dir1) {
    print "ERROR: $dir1 does not exist\n";
    exit 1;
}
if (! -e $dir2) {
    print "ERROR: $dir2 does not exist\n";
    exit 1;
}
if (! -d $dir1) {
    print "ERROR: $dir1 is not a directory\n";
    exit 1;
}
if (! -d $dir2) {
    print "ERROR: $dir2 is not a directory\n";
    exit 1;
}

# Remove trailing slash on directories
$dir1 =~ s{/\z}{}xms;
$dir2 =~ s{/\z}{}xms;

# List of files
my @files_dir1 = ();
my @files_dir2 = ();
my @yaml_files_dir1 = ();
my @yaml_files_dir2 = ();

# Pupulate file lists
find(
    sub {
	return unless -f;
	push @files_dir1, $File::Find::name;
	if ($File::Find::name =~ m{\.(yaml|yml)\z}xms) {
	    push @yaml_files_dir1, $File::Find::name;
	}
    },
    $dir1);
find(
    sub {
	return unless -f;
	push @files_dir2, $File::Find::name;
	if ($File::Find::name =~ m{\.(yaml|yml)\z}xms) {
	    push @yaml_files_dir2, $File::Find::name;
	}
    },
    $dir2);

# Data variables
my @errors = ();
my %inidiff = ();
my %yamldiff = ();

# Loop through files and create diff for INI files
foreach my $file (@files_dir1) {
    $file =~ s{$dir1/}{}xms;
    if (! -f "$dir2/$file") {
	push @errors, "File only in $dir1: $file";
	next;
    }
    my $cfg1 = Config::IniFiles->new( -file => "$dir1/$file" );
    my $cfg2 = Config::IniFiles->new( -file => "$dir2/$file" );

  SECTION1:
    foreach my $section (@{ $cfg1->{sects} }) {
	if (! $cfg2->{e}{$section}) {
	    push @{ $inidiff{$file} }, "  -[$section]";
	    foreach my $parm (@{ $cfg1->{parms}{$section} }) {
		my $val1 = $cfg1->val($section, $parm);
		push @{ $inidiff{$file} }, "    -$parm = $val1";
	    }
	    next SECTION1;
	}
	foreach my $parm (@{ $cfg1->{parms}{$section} }) {
	    my $val1 = $cfg1->val($section, $parm);
	    my $val2 = $cfg2->val($section, $parm);
	    if (!defined $val2) {
		push @{ $inidiff{$file} }, "  [$section]";
		push @{ $inidiff{$file} }, "    -$parm = $val1";
	    }
	    elsif ($val1 ne $val2) {
		push @{ $inidiff{$file} }, "  [$section]";
		push @{ $inidiff{$file} }, "    -$parm = $val1";
		push @{ $inidiff{$file} }, "    -$parm = $val2";
	    }
	}
    }
  SECTION2:
    foreach my $section (@{ $cfg2->{sects} }) {
	if (! $cfg1->{e}{$section}) {
	    push @{ $inidiff{$file} }, "  +[$section]";
	    foreach my $parm (@{ $cfg2->{parms}{$section} }) {
		my $val2 = $cfg2->val($section, $parm);
		push @{ $inidiff{$file} }, "    +$parm = $val2";
	    }
	    next SECTION2;
	}
	foreach my $parm (@{ $cfg2->{parms}{$section} }) {
	    my $val1 = $cfg1->val($section, $parm);
	    my $val2 = $cfg2->val($section, $parm);
	    if (!defined $val1) {
		push @{ $inidiff{$file} }, "  [$section]";
		push @{ $inidiff{$file} }, "    +$parm = $val2";
	    }
	}
    }
}

# Collect errors
foreach my $file2 (@files_dir2) {
    $file2 =~ s{$dir2/}{}xms;
    if (! -f "$dir1/$file2") {
	push @errors, "File only in $dir2: $file2";
    }
}

# Loop through files and create diff for YAML files
foreach my $file (@yaml_files_dir1) {
    $file =~ s{$dir1/}{}xms;
    my $yaml1 = LoadFile "$dir1/$file";
    my $yaml2 = LoadFile "$dir2/$file";

    foreach my $k (keys %{ $yaml1 }) {
	if (!defined $yaml2->{$k}) {
	    push @{ $yamldiff{$file} }, "  -$k : $yaml1->{$k}";
	}
	elsif ($yaml1->{$k} ne $yaml2->{$k}) {
	    push @{ $yamldiff{$file} }, "  -$k : $yaml1->{$k}";
	    push @{ $yamldiff{$file} }, "  -$k : $yaml2->{$k}";
	}
    }
    foreach my $k (keys %{ $yaml2 }) {
	if (!defined $yaml1->{$k}) {
	    push @{ $yamldiff{$file} }, "  +$k : $yaml2->{$k}";
	}
    }
}

# Print errors
foreach my $error (@errors) {
    print "FILE EXISTENCE: $error\n";
}
print "\n";

# Print YAML diffs
foreach my $file (keys %yamldiff) {
    print "YAML diff: $file:\n";
    foreach my $msg (@{ $yamldiff{$file} }) {
	print "  $msg\n";
    }
    print "\n";
}

# Print INI diffs
foreach my $file (keys %inidiff) {
    print "INI sections diff: $file:\n";
    foreach my $msg (@{ $inidiff{$file} }) {
	print "  $msg\n";
    }
    print "\n";
}

# Exit gracefully
exit 0;
