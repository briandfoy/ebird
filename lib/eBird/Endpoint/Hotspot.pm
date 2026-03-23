use v5.38;
use utf8;
no feature qw(module_true);

package  eBird::Endpoint::Hotspot;
use parent qw(eBird::Endpoint::Base);

=encoding utf8

=head1 NAME

eBird::Endpoint::Hotspot -

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item *

=cut

=back

=head2  Hot Spot

=over 4

=item * hotspots_in_region( COUNTRY, [, SUBNATIONAL1], [, SUBNATIONAL2] )

=cut



sub hotspots_in_region ( $self, $region ) {
	state $path_template = 'ref/hotspot/{{regionCode}}';

	my $data = $self->ebird->get(
		args => {
			regionCode => $region->code,
			},
		cache_key     => 'hotspots-' . $region->code,
		json => 0,
		path_template => $path_template,
		);

	$self->parse_location_csv( $data );
	}

=item * info( LOC_ID )

=cut

# {
#   "locId": "L99381",
#   "name": "Stewart Park",
#   "latitude": 42.4613413,
#   "longitude": -76.5054578,
#   "countryCode": "US",
#   "countryName": "United States",
#   "subnational1Name": "New York",
#   "subnational1Code": "US-NY",
#   "subnational2Code": "US-NY-109",
#   "subnational2Name": "Tompkins",
#   "isHotspot": true,
#   "hierarchicalName": "Stewart Park, Tompkins, New York, US",
#   "locID": "L99381"
# }

sub info ( $self, $location_id ) {
	state $path_template = 'ref/hotspot/info/{{locId}}';

	my $data = $self->ebird->get(
		args => {
			locId => $location_id,
			},
		bless_into => 'eBird::Data::Location',
		cache_key => "hotspot-$location_id",
		path_template => $path_template,
		);
	}

=item * nearby( LATLONG, ARGS )

=cut

=begin comment

Name   Values      Default  Description
back  1-30        (none)  Only fetch hotspots which have been visited up to 'back' days ago.
dist  0 - 500     25   The search radius from the given position, in kilometers.
fmt   csv, json   csv  Fetch the records in CSV or JSON format.
lat   -90 - 90         Required. Latitude to 2 decimal places.
lng   -180 - 180       Required. Longitude to 2 decimal places.

=end comment

=cut

sub nearby ($self, $latlong, $args) {
	state $path_template = 'ref/hotspot/geo';

	$args->{'distance'} //= 25;

	my $data = $self->ebird->get(
		args => {},
		bless_into => 'eBird::Data::Location',
		cache_key  => sprintf("nearby-%s^%s-%s", $latlong->lat, $latlong->long, $args->{'distance'}),
		json => 0,
		path_template => $path_template,
		query => {
			lat  => $latlong->lat,
			lng  => $latlong->long,
			dist => $args->{'distance'},
			fmt  => 'csv',
			},
		);

	$self->ebird->parse_location_csv($data);
	}

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

__PACKAGE__;
