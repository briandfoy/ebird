use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Location;
use parent qw(eBird::Data::Base);

use namespace::autoclean;

use eBird::Data::Region ();
use eBird::LatLong ();

=encoding utf8

=head1 NAME

eBird::Data::Location - the representation of a location (hotspot or otherwise)

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the locations that eBird understands.

=head2 Class methods

=over 4

=item * new( ID, NAME )

=cut

my %Registry;

sub new ($class, $id, $name) {
	return $Registry{$id} if ref $Registry{$id};

	$Registry{$id} = bless { id => $id, name => $name }, $class;
	}

=item * new_from_api_response

=cut

=begin comment

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

=end comment

=cut

sub new_from_api_response ($class, $hash) {
	return $Registry{ $hash->{'code'} } if defined $Registry{ $hash->{'code'} };
	my $self = {};

	$self->{'latlong'} = eBird::LatLong->new_from_decimal( $hash->@{qw(latitude longitude)} );
	$self->{'name'}    = $hash->{'result'};
	$self->{'id'}      = $hash->{'code'};
	$self->{'bounds'}  = eBird::LatLongBox->new( $hash->{'bounds'} );
	$self->{'parent'}  = eBird::Data::Region->new_from_api_response($hash->{'parent'});

	# need to look up hotspot (410 Gone if not)

	$Registry{ $hash->{'code'} } = bless $self, $class;
	}

=item * new_from_id(ID)

=cut

sub new_from_id ($class, $id) {
	return unless $id =~ m/\A L \d+ \z/ax;
	$class->new_from_api_response( $class->ebird->region->info($id) );
	}

=back

=head2 Instance methods

=over 4

=item * id

=cut

sub id ($self) { $self->{'id'} }

=item * name

=cut

sub name ($self) { $self->{'name'} }

=item * region

Return a L<eBird::Data::Region> object.

=cut

# https://api.ebird.org/v2/ref/region/info/{{regionCode}}
# https://api.ebird.org/v2/product/lists/{{regionCode}}

sub region ($self) { $self->{'parent'} }

=back

=head2 Tests

=over 4

=item * contains( LATLONG )

Returns true if the coordinates of C<LATLONG> are in the bounding box for
the region.

=cut



=item * is_hotspot

=cut

sub is_hotspot ($self) { 0 }

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
