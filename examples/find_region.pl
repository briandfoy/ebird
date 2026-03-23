#!perl
use v5.10;
use lib qw(lib);

use eBird;
use eBird::LatLong;
use eBird::Nearby;

my $ebird   = eBird->new;
my $latlong = eBird::LatLong->new_from_decimal( 40.748817, -73.985428 );
say "LATLONG: " . dumper( $latlong );

my $nearby = eBird::Nearby->new( $latlong, $ebird );
say "NEARBY: " . dumper( $nearby );

my $region = $nearby->region;
say "REGION: " . dumper($region);

sub dumper { state $rc = require Data::Dumper; Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump }


__END__
US-NY-047
US-NY-061
US-NJ-017

