#!perl
use v5.38;
use lib qw(lib);

use eBird;
use eBird::LatLong;
use eBird::Nearby;

my $ebird   = eBird->new;
my $latlong = eBird::LatLong->new_from_decimal( 40.748817, -73.985428 );

my $nearby = eBird::Nearby->new( $latlong, $ebird );

my $regions = $nearby->region;

foreach my $region ( values $regions->%* ) {
	my $d = $latlong->distance_to( $region );
	printf "%4d %s   | %s\n", $d, $region->code, $region->label;

	}

sub dumper { state $rc = require Data::Dumper; Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump }


__END__
US-NY-047
US-NY-061
US-NJ-017

