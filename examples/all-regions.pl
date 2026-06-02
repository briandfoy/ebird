#!perl
use v5.10;
use strict;

use FindBin qw($Bin);
use lib qw($Bin/../lib);

use eBird;
$ENV{'EBIRD_LOG_LEVEL'} = 'trace';

my $ebird = eBird->new( request_interval => 1 );

my $countries = $ebird->region->countries;

my @subnationals;
foreach my $country ( $countries->@* ) {
	say dumper($country);
	my $subnationals = $ebird->region->subregion_list_for( 'subnational1', $country->short_code );
	push @subnationals, [ $country, $subnationals ];
	}

say dumper(\@subnationals);

# many areas do not have subnational regions
foreach my $tuple ( @subnationals ) {
	my( $country, $subnationals1 ) = $tuple->@*;
	foreach my $sub1 ( $subnationals1->@* ) {
		my $subnationals2 = $ebird->region->subregion_list_for( 'subnational2', $sub1->code );
		foreach my $sub2 ( $subnationals2->@* ) {
			say dumper($sub2);
			}
		}
	}

sub dumper { state $rc = require Data::Dumper; Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump }
