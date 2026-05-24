use v5.38;
use utf8;
use lib qw(lib);

use Test::More 1.0;

use eBird;
use eBird::IO;

my $class  = 'eBird::LatLong';
my $method = 'new_from_decimal';

=encoding utf8

=head1 NAME

t/latlong.t -

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/latlong.t

=head1 DESCRIPTION

Most of the eBird API endpoints that deal with geocoordinates want latitude
and longitude in decimal with up to two decimal places. This module handles
all of that, whether you create the object directly or from a more sophisticated
geocoordinates module.

=cut

subtest sanity => sub {
	use_ok $class;
	can_ok $class, $method, qw(lat latitude long longitude new_from_any);
	} or do {
		done_testing();
		exit 1;
		};

subtest $method => sub {
	subtest 'bad' => sub {
		my $warnings;
		open my $sfh, '>', \$warnings
			or die "Could not open string filehandle: $!";

		local $SIG{'__WARN__'} = sub { $warnings .= $_[0] };
		local $SIG{'__DIE__'}  = sub { $warnings .= $_[0] };

		my $ebird = eBird->new(
			io => eBird::IO->new(
					output_fh => $sfh,
					error_fh  => $sfh,
				)
			);

		my @table = (
			[ 'no args',                                   [],              qr/Too few arguments/ ],
			[ 'latitude only, in range',                   [ 37 ],          qr/Too few arguments/ ],
			[ 'latitude only, out of range',               [ 137 ],         qr/Too few arguments/ ],
			[ 'both non-numeric',                          [qw( abc xyz )], qr/must be in/        ],
			[ 'latitude numeric, longitude non-numeric',   [ 29, 'hjk' ],   qr/must be in/        ],
			[ 'latitude non-numeric, longitude numeric',   [ 'XF', 140 ],   qr/must be in/        ],
			[ 'latitude in range, longitude out of range', [    7, 361] ,   qr/must be in/        ],
			[ 'latitude out of range, longitude in range', [  450, 11],     qr/must be in/        ],
			);

		foreach my $row ( @table ) {
			$warnings = '';
			my( $label, $args, $pattern ) = $row->@*;
			subtest $label => sub {
				my $obj = eval { $class->$method( $args->@*, $ebird ) };
				ok ! defined $obj, 'no object for bad args';
				like $warnings, $pattern, 'warning matches';
				};
			}
		};

	subtest 'good' => sub {
		my @table = (
			[ 'zeros',              [   0,    0 ] ],
			[ 'zero, highest',      [   0,  180 ] ],
			[ 'zero, lowest',       [   0, -180 ] ],
			[ 'lowest, zero',       [ -90,    0 ] ],
			[ 'highest, zero',      [  90,    0 ] ],
			[ 'highest, lowest',    [  90, -180 ] ],
			[ 'highest, highest',   [  90,  180 ] ],
			[ 'lowest, lowest',     [ -90, -180 ] ],
			[ 'lowest, highest',    [ -90,  180 ] ],
			[ '4, 4',               [ -60.1234, 37.9876 ] ],
			);

		foreach my $row ( @table ) {
			my( $label, $args, $warning ) = $row->@*;
			subtest $label => sub {
				my $obj = eval { $class->$method( $args->@* ) };
				isa_ok $obj, $class;
				can_ok $obj, qw(lat long);
				is $obj->lat,  sprintf('%.2f', $args->[0]), 'latitude round trips';
				is $obj->long, sprintf('%.2f', $args->[1]), 'longitude round trips';

				is $obj->lat,  $obj->latitude,  'lat and latitude is the same';
				is $obj->long, $obj->longitude, 'lon and longitude is the same';
				};
			}
		};
	};

subtest 'new_from_any' => sub {
	my $method = 'new_from_any';
	can_ok $class, $method;

	subtest $class => sub {
		my $obj = $class->new_from_decimal( rand(180)-90, rand(360)-180 );
		isa_ok $obj, $class;

		my $any = $class->$method( $obj );
		isa_ok $any, $class;
		is $any->lat,  $obj->lat,  'latitudes match';
		is $any->long, $obj->long, 'longitude match';
		}
	};

subtest 'elevation' => sub {
	pass(); return;
	subtest 'sitka' => sub {
		my $longitude          = '-135.33';
		my $latitude           =   '57.05';
		my $expected_elevation =   '10';

		my $obj = $class->$method( $latitude, $longitude );
		isa_ok $obj, $class;

		is $obj->latitude,  $latitude,  'latitude matches';
		is $obj->longitude, $longitude, 'longitude matches';

		my $elevation = $obj->elevation;
		is $elevation, $expected_elevation, 'elevation for Sitka is right';
		};
	};

subtest 'region' => sub {
	my $expected_region = 'US-AK-220';

	subtest 'sitka' => sub {
		my $longitude          = '-135.33';
		my $latitude           =   '57.05';

		my $latlong = $class->$method( $latitude, $longitude );
		isa_ok $latlong, $class;
		can_ok $latlong, qw(region_info);

		my $region_info = $latlong->region_info;

		is $region_info->region,  $expected_region,  'region matches';
		ok $region_info->region->contains($latlong),  'region contains geo-coordinate';
		};
	};

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
