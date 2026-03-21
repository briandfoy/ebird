#!/Users/brian/bin/perl
use v5.36;

use lib qw(../lib lib);
use eBird;

my $ebird = eBird->new( api_key => $ENV{'EBIRD_API_KEY'} );

say dumper( $ebird->region->region_info_for($ARGV[0]) );

sub dumper { state $rc = require Data::Dumper; Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump }
