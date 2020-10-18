#!/usr/bin/env perl

# run all defined tests in headless mode

# - example usage (run all tests.  Print them to STDOUT without prompting for user action. Save to state file):
#  - TEST_SWAKS=../../swaks bin/run-all.pl
# - example usage (only run tests that failed during the last run-all.pl execution):
#  - TEST_SWAKS=../../swaks bin/run-all.pl --errors

# this leaves var/results.* files laying around, should prune them periodically

use strict;
use FindBin qw($Bin);
use Getopt::Long;

my $opts = {};
GetOptions($opts, 'errors|e!', 'winnow|w!') || die "Couldn't understand options\n";

my $home     = "$Bin/..";
my $runTests = "$home/bin/run-tests.pl";

opendir(D, $home) || die "Couldn't opendir $home: $!\n";
my @tests = grep /^_/, readdir(D);
closedir(D);

my $vard = "$home/var";
if (!-d $vard) {
	mkdir($vard) || die "Couldn't make $vard: $!\n";
}

my $nextfile = "$vard/results." . time();
my $prevfile;

if ($opts->{errors} || $opts->{winnow}) {
	opendir(DIR, "$home/var") || die "Couldn't opendir $home/var\n";
	my $file = (sort(grep(/^results./, readdir(DIR))))[-1]; # get the newest file
	closedir(DIR);

	if ($file) {
		$prevfile = "$home/var/$file";
	}
	else {
		die "Unable to find a var/results.* file to use for previous errors\n";
	}
}

foreach my $test (sort @tests) {
	if ($opts->{errors}) {
		system($runTests, '--errors', '--infile', $prevfile, $test);
	}
	elsif ($opts->{winnow}) {
		system($runTests, '--errors', '--infile', $prevfile, '--outfile', $nextfile, $test);
	}
	else {
		system($runTests, '--headless', '--outfile', $nextfile, $test);
	}
}
