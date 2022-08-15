# -*- mode: perl; perl-indent-level: 2 -*-
# vim: ts=8 sw=2 sts=2 noexpandtab

use strict; use warnings;
use Memoize 0.45 qw(memoize unmemoize);
# $Memoize::Storable::Verbose = 0;

sub test_dbm;
my $module;
BEGIN {
  $module = 'Memoize::Storable';
  eval "require $module" or do {
    print "1..0 # Skipped: Could not load $module\n";
    exit 0;
  };
}

sub i {
  $_[0];
}

sub c119 { 119 }
sub c7 { 7 }
sub c43 { 43 }
sub c23 { 23 }
sub c5 { 5 }

sub n {
  $_[0]+1;
}

print "1..5\n";

my $file;
$file = "storable$$";
1 while unlink $file;
test_dbm $file;
1 while unlink $file;

if (eval { Storable->VERSION('0.609') }) {
  { tie my %cache, 'Memoize::Storable', $file, 'nstore' or die $! }
  print Storable::last_op_in_netorder() ? "ok 5\n" : "not ok 5\n";
  1 while unlink $file;
} else {
  print "ok 5 # skip Storable $Storable::VERSION too old for last_op_in_netorder\n";
}

sub test_dbm {
  my $testno = 1;

  tie my %cache, $module, @_ or die $!;

  memoize 'c5', 
  SCALAR_CACHE => [HASH => \%cache],
  LIST_CACHE => 'FAULT'
    ;

  my $t1 = c5();	
  my $t2 = c5();	
  print (($t1 == 5) ? "ok $testno\n" : "not ok $testno\n");
  $testno++;
  print (($t2 == 5) ? "ok $testno\n" : "not ok $testno\n");
  unmemoize 'c5';
  1;
  1;

  # Now something tricky---we'll memoize c23 with the wrong table that
  # has the 5 already cached.
  memoize 'c23', 
  SCALAR_CACHE => [HASH => \%cache],
  LIST_CACHE => 'FAULT'
    ;

  my $t3 = c23();
  my $t4 = c23();
  $testno++;
  print (($t3 == 5) ? "ok $testno\n" : "not ok $testno\n");
  $testno++;
  print (($t4 == 5) ? "ok $testno\n" : "not ok $testno\n");
  unmemoize 'c23';
}
