use v5.38;
use utf8;
use lib qw(lib);

use Test::More 1.0;

use eBird;
use eBird::IO;
use Mojo::JSON qw(decode_json);

my $class         = 'eBird::LatLongBox';
my $latlong_class = 'eBird::LatLong';

=encoding utf8

=head1 NAME

t/latlongbox.t - test the bounding box stuff

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/latlongbox.t

=head1 DESCRIPTION

=cut

my( $latlong1, $latlong2 );

subtest sanity => sub {
	use_ok $class;
	can_ok $class, qw(new new_from_api_response contains encloses is_enclosed_by min max);
	} or do {
		done_testing();
		exit 1;
		};

subtest 'mock api response' => sub {
	my $response = mock_api_response();
	isa_ok $response, ref {};
	ok exists $response->{'bounds'}, 'bounds key exists';
	};

subtest 'new' => sub {
	subtest 'bad args' => sub {
		my $warnings;
		local $SIG{__WARN__} = sub { $warnings .= $_[0] };
		my $b = $class->new( undef, undef );
		ok ! defined $b, 'bad args return undef';
		like $warnings, qr/Both arguments/, 'warning is as expected';
		};

	subtest 'good args' => sub {
		my $b = $class->new(
			$latlong_class->new_from_decimal( 45, -137 ),
			$latlong_class->new_from_decimal( 47, -123 )
			);
		isa_ok $b, $class;
		};
	};

subtest 'contains' => sub {
	my $latlong_box = $class->new_from_api_response( mock_api_response() );

	subtest 'inside' => sub {
		my $p = inside_point();
		isa_ok $p, $latlong_class;
		ok $latlong_box->contains($p), 'the box contains the inside point';
		ok $latlong_box->contains( $latlong_box->min ), 'the box contains its own min';
		ok $latlong_box->contains( $latlong_box->max ), 'the box contains its own max';
		};

	subtest 'outside' => sub {
		my $p = outside_point();
		isa_ok $p, $latlong_class;
		ok ! $latlong_box->contains($p), 'the box does not contain the outside point';
		ok $latlong_box->contains( $latlong_box->min ), 'the box contains its own min';
		ok $latlong_box->contains( $latlong_box->max ), 'the box contains its own max';
		};
	};

sub show_box ($latlong_box) {
	join "\n", map { join ', ', $latlong_box->$_->latitude, $latlong_box->$_->longitude } qw(min max);
	}

subtest 'encloses' => sub {
	my $latlong_box = $class->new_from_api_response( mock_api_response() );
	isa_ok $latlong_box, $class;
	can_ok $latlong_box, qw(encloses is_enclosed_by);

	subtest 'inside' => sub {
		my $box = inside_box();
		isa_ok $box, $class;

		ok $latlong_box->encloses($box), 'the larger box encloses the smaller box';
		ok $box->is_enclosed_by($box), 'the smaller box is enclosed by the bigger box';
		ok $box->overlaps($latlong_box), 'the smaller box overlaps the box';
		ok $latlong_box->overlaps($box), 'the box overlaps the smaller box';

		ok ! $box->encloses($latlong_box), 'the smaller box does not enclose the bigger box';
		ok ! $latlong_box->is_enclosed_by($box), 'the bigger box is not enclosed by the smaller box';
		};

	subtest 'outside' => sub {
		my $box = outside_box();
		isa_ok $box, $class;

		ok ! $latlong_box->encloses($box), 'the box does not enclose the outside box';
		ok ! $box->is_enclosed_by($latlong_box), 'the outside box is not enclosed by the box';
		ok ! $box->overlaps($latlong_box), 'the outside box does not overlap the box';
		ok ! $latlong_box->overlaps($box), 'the box does not overlap the outside box';
		};
	};

subtest 'new_from_api_response' => sub {
	my $response = mock_api_response();
	isa_ok $response, ref {};
	ok exists $response->{'bounds'}, 'bounds key exists';

	my $latlongbox = $class->new_from_api_response($response);
	isa_ok $latlongbox, $class;
	};

sub inside_box () {
	my $b = mock_api_response()->{'bounds'};

	my $lat_thirds  = abs($b->{'maxY'} - $b->{'minY'}) / 3;
	my $long_thirds = abs($b->{'maxX'} - $b->{'minX'}) / 3;

	my $p1 = $latlong_class->new_from_decimal(
		$b->{'minY'} + $lat_thirds,
		$b->{'minX'} + $long_thirds,
		);

	my $p2 = $latlong_class->new_from_decimal(
		$b->{'minY'} + 2*$lat_thirds,
		$b->{'minX'} + 2*$long_thirds,
		);

	$class->new( $p1, $p2 );
	}

sub outside_box () {
	my $b = mock_api_response()->{'bounds'};

	my $p1 = $latlong_class->new_from_decimal(
		$b->{'minY'} - 2,
		$b->{'minX'} - 2,
		);

	my $p2 = $latlong_class->new_from_decimal(
		$b->{'minY'} - 1,
		$b->{'minX'} - 1,
		);

	$class->new( $p1, $p2 );
	}

sub inside_point () {
	my $b = mock_api_response()->{'bounds'};

	my $latitude  = ($b->{'minY'} + $b->{'maxY'}) / 2;
	my $longitude = ($b->{'minX'} + $b->{'maxX'}) / 2;

	$latlong_class->new_from_decimal( $latitude, $longitude );
	}

sub outside_point () {
	my $b = mock_api_response()->{'bounds'};

	my $latitude  = $b->{'minY'} - 1;
	my $longitude = $b->{'minX'} - 1;

	$latlong_class->new_from_decimal( $latitude, $longitude );
	}

sub mock_api_response () {
	my $json = <<~'JSON';
	{
	  "bounds": {
		"minX": -74.048310194408,
		"maxX": -73.94831019440801,
		"minY": 40.6991882100338,
		"maxY": 40.7991882100338
	  },
	  "result": "Church of the Holy Apostles & adj. Rec. Area",
	  "code": "L9960204",
	  "type": "loc",
	  "parent": {
		"result": "New York, New York, United States",
		"code": "US-NY-061",
		"type": "subnational2",
		"parent": {
		  "result": "New York, United States",
		  "code": "US-NY",
		  "type": "subnational1",
		  "parent": {
			"result": "United States",
			"code": "US",
			"type": "country",
			"longitude": 0,
			"latitude": 0
		  },
		  "longitude": 0,
		  "latitude": 0
		},
		"longitude": 0,
		"latitude": 0
	  },
	  "longitude": -73.998310194408,
	  "latitude": 40.7491882100338
	}
	JSON

	return decode_json($json);
	}

done_testing();

=back

=head1 TO DO

=head1 SEE ALSO

=over 4

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut
