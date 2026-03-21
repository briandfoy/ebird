#!/Users/brian/bin/perl
use v5.36;

use lib qw(../lib lib);
use eBird;

my $ebird = eBird->new( api_key => $ENV{'EBIRD_API_KEY'} );

say $ebird->country_from_code($ARGV[0])->name;
