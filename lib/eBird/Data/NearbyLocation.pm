use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::NearbyLocation;
use parent qw(eBird::Data::Base);

use namespace::autoclean;

=encoding utf8

=head1 NAME

eBird::Data::NearbyLocation - the representation of a location (hotspot or otherwise)

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the locations that eBird understands.

=head2 Class methods

=over 4

=item * new( ID, HASH )

=cut

my %Registry;

sub new ($class, $row) {
	return $Registry{$row->{'location_id'}} if ref $Registry{$row->{'location_id'}};

	my $self = {};

	$self->{'location_id'} = $row->{'location_id'};
	$self->{'region_code'} = $row->{'subnational2'} // $row->{'subnational1'} //  $row->{'country'} // 'world';
	$self->{'latlong'} = eBird::LatLong->new_from_decimal( $row->@{qw(latitude longitude)} );
	$self->{'all_time_species'} = $row->{'all_time_species'};
	$self->{'last_observation'} = $row->{'last_observation'};

	$Registry{$row->{'location_id'}} = bless $self, $class;
	}

=back

=head2 Instance methods

=over 4

=item * all_time_species

=cut

sub all_time_species ($self) { $self->{'all_time_species'} }

=item * last_observation

=cut

sub last_observation ($self) { $self->{'last_observation'} }

=item * location

Constructs the L<eBird::Data::Location> object using the C<location_id>, and
returns the object.

=cut

sub location ($self) {
	eBird::Data::Location->new_from_id( $self->location_id );
	}

=item * location_id

=cut

sub location_id ($self) { $self->{'location_id'} }

=item * latlong

=cut

sub latlong ($self) { $self->{'latlong'} }

=item * name

=cut

sub name ($self) { $self->{'name'} }

=item * region_code

=cut

sub region_code ($self) { $self->{'region_code'} }

=item * region

Return a L<eBird::Data::Region> object.

=cut

# https://api.ebird.org/v2/ref/region/info/{{regionCode}}
# https://api.ebird.org/v2/product/lists/{{regionCode}}

sub region ($self) { $self->{'parent'} }

=back

=head2 Tests

=over 4

=item * is_hotspot

=cut

sub is_hotspot ($self) { $self->{'hotspot'} }

=item * is_location

Always returns true.

=cut

sub is_location ($self) { 1 }

=item * is_private

=cut

sub is_private ($self) { 0 }

=item * is_region

Always returns false.

=cut

sub is_region ($self) { 0 }

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
