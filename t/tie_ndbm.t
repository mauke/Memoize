use strict; use warnings;
use Memoize 0.45 qw(memoize unmemoize);
use Fcntl;

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

sub test_dbm;
my $module;
BEGIN {
  $module = 'Memoize::NDBM_File';
  eval "require $module" or do {
    print "1..0 # Skipped: Could not load $module\n";
    exit 0;
  };
}

print "1..4\n";

my $file;
$file = "md$$";
1 while unlink $file, "$file.dir", "$file.pag", "$file.db";
test_dbm $file, O_RDWR | O_CREAT, 0666;
1 while unlink $file, "$file.dir", "$file.pag", "$file.db";

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
