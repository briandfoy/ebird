use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::LocationInfo;
use parent qw(eBird::Data::Base);

use eBird;
use eBird::RegionType;

=encoding utf8

=head1 NAME

eBird::Data::LocationInfo - the representation of location information

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the information eBird tracks about a region.

=over 4

=item * adjacent_regions

Retrieves the regions that touch this region.

=cut

sub adjacent_regions ($self) {
	eBird->new->geo->adjacent_regions( $self->code );
	}

=item * contains( LATLONG )

Returns true if the coordinates of C<LATLONG> are in the bounding box for
the region.

=cut

sub contains ($self, $latlong) {
	my $B = $self->bounds;

	my $r = ( $B->minX <= $latlong->long and $latlong->long <= $B->maxX )
		&&
	( $B->minY <= $latlong->lat  and $latlong->lat  <= $B->maxY );
return $r unless $r;
	printf "%s <= %s <= %s\n", $B->minX, $latlong->long, $B->maxX;
	printf "%s <= %s <= %s\n", $B->minY, $latlong->lat,  $B->maxY;
	printf "%s: %d\n", $self->parent->code, $r;
	$r;
	}

=item * label

=cut

sub label ($self) { $self->result }

=item * region

=cut

sub region ($self) { $self->code }

=item * type

Returns an L<eBird::RegionType> object.

=cut

sub type ($self) {
	eBird::RegionType->new_for( $self->{'type'} );
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

__END__

bless( {
  "bounds" => {
    "maxX" => "179.773408",
    "maxY" => "71.390685",
    "minX" => "-179.150558",
    "minY" => "18.909858"
  },
  "code" => "US",
  "latitude" => "45.1502715",
  "longitude" => "0.311425",
  "result" => "United States",
  "type" => "country"
}, 'eBird::Data::RegionInfo' )

  bless( {
    "bounds" => {
      "maxX" => "-73.7199760975619",
      "maxY" => "40.6525033107414",
      "minX" => "-73.8199760975619",
      "minY" => "40.5525033107414"
    },
    "code" => "L6587285",
    "latitude" => "40.6025033107414",
    "longitude" => "-73.7699760975619",
    "parent" => {
      "code" => "US-NY-081",
      "latitude" => 0,
      "longitude" => 0,
      "parent" => {
        "code" => "US-NY",
        "latitude" => 0,
        "longitude" => 0,
        "parent" => {
          "code" => "US",
          "latitude" => 0,
          "longitude" => 0,
          "result" => "United States",
          "type" => "country"
        },
        "result" => "New York, United States",
        "type" => "subnational1"
      },
      "result" => "Queens, New York, United States",
      "type" => "subnational2"
    },
    "result" => "Norton Basin Natural Resource Area",
    "type" => "loc"
  }, 'eBird::Data::RegionInfo' ),
