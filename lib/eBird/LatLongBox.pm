use v5.38;
use utf8;
no feature qw(module_true);

package eBird::LatLongBox;
use namespace::autoclean;
use Carp qw(carp);
use List::Util qw();

use eBird;
use eBird::IO;
use eBird::Nearby;

=encoding utf8

=head1 NAME

eBird::LatLongBox - a bounding box to represent a geographic rectangular area

=head1 SYNOPSIS

	use eBird::LatLongBox;

=head1 DESCRIPTION

Most of the eBird API endpoints that deal with geocoordinates want latitude
and longitude in decimal with up to two decimal places. This module handles
all of that, whether you create the object directly or from a more sophisticated
geocoordinates module.

=over 4

=item * new_from_decimal( LATLONG1, LATLONG2 )

Creates a new L<eBird::LatLongBox> object from L<eBird::LatLong> objects. These
do not need to be passed in any order.

=cut

sub new ($class, $latlong1, $latlong2) {
	state $arg_class = 'eBird::LatLong';
	unless( $latlong1 isa $arg_class and $latlong2 isa $arg_class ) {
		carp "Both arguments to new must be $arg_class objects";
#		say "NEW: " . eBird::Util::dumper( [$latlong1, $latlong2] );
		return;
		}

	my @L = ($latlong1, $latlong2);

    # we are going to rearrange the points to make the box. It doesn't matter
    # if the min.max are the actual points. When they aren't, the original
    # points are the two other corners of the box.
	my $max = $arg_class->new_from_decimal(
		List::Util::max( map {$_->latitude } @L ),
		List::Util::max( map {$_->longitude} @L )
		);

	my $min = $arg_class->new_from_decimal(
		List::Util::min( map {$_->latitude } @L ),
		List::Util::min( map {$_->longitude} @L )
		);

	bless {
		max => $max,
		min => $min
		}, $class;
	}

=item * new_from_api_response(HASH)

Given a rw hash from an eBird API response, convert the data in the C<bounds>
key into an object.

=cut

sub new_from_api_response ($class, $hash) {
	state $arg_class = 'eBird::LatLong';
	unless( exists $hash->{bounds} ) {
		carp "hash argument to new_from_api_response does not have a 'bounds' key";
		return;
		}

	my $bounds   = $hash->{'bounds'};
	my $latlong1 = $arg_class->new_from_decimal( map { $bounds->{$_} } qw(minY minX) );
	my $latlong2 = $arg_class->new_from_decimal( map { $bounds->{$_} } qw(maxY maxX) );

	$class->new( $latlong1, $latlong2 );
	}

=back

=head2 Instance methods

=over 4

=item * contains( LATLONG )

Returns true if the box contains the L<eBird::LatLong> point, and false otherwise.

=cut

sub contains ($self, $latlong) {
	state $arg_class = 'eBird::LatLong';
	unless( $latlong isa $arg_class ) {
		carp "The argument to contains must be an $arg_class object";
		return;
		}

	( $self->min->latitude  <= $latlong->latitude  <= $self->max->latitude  )
	&&
	( $self->min->longitude <= $latlong->longitude <= $self->max->longitude );
	}

=item * encloses( LATLONGBOX )

Returns true if this box completely encloses C<LATLONG_BOX>.

See C<is_enclosed_by> for the converse test.

=cut

sub encloses ($self, $latlong_box) {
	$self->contains($latlong_box->max) and $self->contains($latlong_box->min);
	}

=item * is_enclosed_by( LATLONG_BOX )

Returns true if both points of this box are inside (or on the edge) of C<LATLONG_BOX>,
and false otherwise.

=cut

sub is_enclosed_by ($self, $latlong_box) {
	$latlong_box->contains($self->max) and $latlong_box->contains($self->min);
	}

=item * max

=item * min

Returns the points used by the box. These may be rearranged from the original
points.

=cut

sub max ($self) { $self->{'max'} }
sub min ($self) { $self->{'min'} }

=item * overlaps( LATLONG_BOX )

Returns true if this box overlaps C<LATLONG_BOX>.

See C<encloses> for the converse test.

=cut

sub overlaps ($self, $latlong_box) {
	$self->contains($latlong_box->max) or $self->contains($latlong_box->min)
		or
	$latlong_box->contains($self->max) or $latlong_box->contains($self->min)
	}

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT

Copyright 2023-2026, brian d foy C<< <briandfoy@pobox.com> >>

=cut

__PACKAGE__;
