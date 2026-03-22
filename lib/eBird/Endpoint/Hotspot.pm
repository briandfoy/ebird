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



sub hotspots_in_region ( $self, $country, $subnational1 = undef, $subnational2 = undef ) {
	state $path_template = 'ref/hotspot/{{ region_code }}';

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);
	my $cache_key = "hotspots-$region";

	my $data = $self->get(
		path_template => $path_template,
		cache_key     => $cache_key,
		args => {
			region_code => $region,
			},
		json => 0,
		);

	$self->parse_location_csv( $data );
	}

=item * hotspot_info( LOC_ID )

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

sub hotspot_info ( $self, $location_id ) {
	state $path_template = 'ref/hotspot/info/{{ locid }}';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "hotspot-$location_id",
		args => {
			locid => $location_id,
			},
		);

$self->logger->debug( dumper( $data ) );
	unless( keys $data->%* ) {
		$self->logger->warn( "There is no information for hotspot <$location_id>" );
		}

	eBird::Hotspot->new($data)
	}

=item * nearby_hotspots( LATITUDE, LONGITUDE, DISTANCE )

=cut

sub nearby_hotspots ($self, $latitude, $longitude, $distance = 25) {
	state $path_template = 'ref/hotspot/geo';
	state $cache;

	$latitude  = sprintf '%.2f', $latitude;
	$longitude = sprintf '%.2f', $longitude;

	return $cache->{$latitude}{$longitude}{$distance}
		if defined $cache->{$latitude}{$longitude}{$distance};

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "nearby-$latitude^$longitude-$distance",
		args => {},
		query => {
			lat  => $latitude,
			lng  => $longitude,
			dist => $distance,
			},
		json => 0,
		);

	$self->parse_location_csv( $data );
	}

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
