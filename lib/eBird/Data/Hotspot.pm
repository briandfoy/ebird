use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Hotspot;
use parent qw(eBird::Data::Base);

use namespace::autoclean;

=encoding utf8

=head1 NAME

eBird::Data::Hotspot - the representation of a location (hotspot or otherwise)

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the hotspot that eBird understands.

=head2 Class methods

=over 4

=cut

my %Registry;

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

sub new_from_api_response ($class, $hash) {
	return $Registry{ $hash->{'locId'} } if defined $Registry{ $hash->{'locId'} };
	my $self = {};

	$self->{'location_id'}  = $hash->{'locId'};
	$self->{'hotspot'}      = $hash->{'isHotspot'} ? 1 : 0;

	$Registry{ $hash->{'locId'} } = bless $self, $class;
	}

=item * new_from_id(ID)

=cut

sub new_from_id ($class, $id //= '') {
	return unless $id =~ m/\A L \d+ \z/ax;
	$class->ebird->hotspot->info($id);
	}

=back

=head2 Instance methods

=over 4

=item * location_id

Returns the id of the Location.

=cut

sub location_id ($self) { $self->{'id'} }

=item * is_hotspot

Always returns true, or it should, because this is a Hotspot object.

=cut

sub is_hotspot ($self) { $self->{'hotspot'} }

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
