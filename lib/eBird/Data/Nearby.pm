use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Nearby;
use parent qw(eBird::Data::Base);

use namespace::autoclean;
use eBird::Data::NearbyLocation;
use eBird::Util ();

=encoding utf8

=head1 NAME

eBird::Data::Nearby - the representation of a location (hotspot or otherwise)

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the hotspot that eBird understands.

=head2 Class methods

=over 4

=item * new_from_api_response

=cut

=begin comment

{
  "locId": "L99381",
  "name": "Stewart Park",
  "latitude": 42.4613413,
  "longitude": -76.5054578,
  "countryCode": "US",
  "countryName": "United States",
  "subnational1Name": "New York",
  "subnational1Code": "US-NY",
  "subnational2Code": "US-NY-109",
  "subnational2Name": "Tompkins",
  "isHotspot": true,
  "hierarchicalName": "Stewart Park, Tompkins, New York, US",
  "locID": "L99381"
}

=end comment

=cut

=item * parse_location_csv

=cut

sub _parse_location_csv ( $csv_data ) {
	state $headers = [
		qw(
			location_id country subnational1 subnational2 latitude longitude
			location_name all_time_species last_observation
		)
		];

	eBird::Util::parse_csv( $csv_data, $headers );
	}

sub new_from_api_response ($class, $csv) {
	my $self = {};

	foreach my $row ( _parse_location_csv($csv)->@* ) {
		push $self->{'locations'}->@*, eBird::Data::NearbyLocation->new($row);
		}

	bless $self, $class;
	}

=item * new_from_id(ID)

=cut

sub new_from_id ($class, $id //= '') {
	return unless $id =~ m/\A L \d+ \z/ax;
	$class->new_from_api_response( $class->ebird->hotspot->info($id) );
	}

=back

=head2 Instance methods

=over 4

=item * locations

Returns the nearby locations as a list of L<eBird::Data::NearbyLocation>
objects.

=cut

sub locations ($self) { $self->{'locations'} }

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
