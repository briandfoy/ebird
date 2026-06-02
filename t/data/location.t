use v5.38;

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../lib";

my $class = 'eBird::Data::Location';

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, qw(new new_from_id new_from_api_response);
	};

subtest 'new_from_id' => sub {
	subtest 'bad argument lists' => sub {
		my @args = ( undef, '', 'US-NY-001', 'K1234', '1234', 'LL1234', 'S1234' );
		foreach my $arg ( @args ) {
			my $location = $class->new_from_id($arg);
			ok ! defined $location, 'bad argument return undef';
			}
		};

	subtest 'good arguments' => sub {
		my %expected = (
			id   => 'L7693418',
			name => 'Martin Van Buren National Historic Site',
			inside  => eBird::LatLong->new_from_decimal( 42.37, -73.67 ),
			outside => eBird::LatLong->new_from_decimal( 43.00, -73.67 ),
			);
		my $location = $class->new_from_id( $expected{'id'} );
		isa_ok $location, $class;
		ok $location->is_location, 'Location is a location';
		ok ! $location->is_region, 'Locaiton is not a region';

		is $location->id, $expected{'id'}, 'ID round trips';
		is $location->name, $expected{'name'}, 'location name is correct';

		ok $location->parent->is_region, 'parent is a region';
		ok ! $location->parent->is_location, 'parent is not a location';

		ok $location->region->is_region, 'parent is a region';
		ok ! $location->region->is_location, 'parent is not a location';

		ok   $location->contains( $expected{'inside'}  ), 'contains() returns true for inside point';
		ok ! $location->contains( $expected{'outside'} ), 'contains() returns false for inside point';
		};
	};

done_testing();
`	`
