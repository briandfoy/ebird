use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Nearby;
use namespace::autoclean;

use Exporter qw(import);
use List::Util qw(first);

use eBird;
use eBird::LatLong;

use B;
use Carp;

our @EXPORT;
our @EXPORT_OK;
our %EXPORT_TAGS;


=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

This module collects the various details about the latitude and longitude
so you can make repeated queries with the same coordinates, or make several
objects with different coordinates.

=over 4

=item * new( eBird::LatLong [, EBIRD] )

Create a new instance with an L<eBird> and L<eBird::LatLong> objects.

If you have geocoordinates from another source, you can use C<new_from_any> which
will create the L<eBird::LatLong> for you.

=cut

sub new ($class, $latlong, $ebird = eBird->new) {
	my @errors;
	push @errors, 'First argument must be an eBird::LatLong object' unless $latlong isa 'eBird::LatLong';
	push @errors, 'Second argument must be an eBird object' unless $ebird isa 'eBird';
	if( @errors ) {
		carp join "\n", @errors;
		return;
		}

	bless {
		ebird   => $ebird,
		latlong => $latlong,
		}, $class;
	}

=item * new_from_any( ANY [, EBIRD] )

Use any object that responds to the right methods

The latitude methods are one of C<lat>, C<latitude>, or C<y>.

The longitude methods are one of C<lon>, C<longitude>, C<lon>, or C<x>.


=cut

sub new_from_any ( $class, $any, $ebird = eBird->new ) {
	my $latlong = eBird::LatLong->new_from_any($any);
	$class->new( $latlong, $ebird );
	}

=back

=head2 Instance methods

=over 4

=item * ebird

Returns the internal L<eBird> object.

=cut

sub ebird ($self) { $self->{'ebird'} }

=item * latlong

Returns the internal L<eBird::LatLong> object.

=cut

sub latlong ($self) { $self->{'latlong'} }

=item * historic_observations( ANY_DATE )

=cut

sub historic_observations ($self, $any_date) {

	}

=item * hotspots

=cut

sub hotspots ($self) {

	}

=item * species_observation( SPECIES )

=cut

sub species_observation ($self, @species) {

	}

=item * recent_notable_observations

=cut

sub recent_notable_observations ($self) {

	}

=item * recent_observations

=cut

sub recent_observations ($self) {

	}

=item * region

Returns the region for the L<eBird::Nearby> object.

This isn't something that the eBird API supplies directly, so we guess a little
by looking for

=cut

sub region ($self) {
	my $dist = 32;

	my $data = $self->ebird->hotspot->nearby( $self->latlong, { dist => $dist });
	my %d =
		map  { $_->parent->code, $_ }
		grep { $_->contains($self->latlong) }
		map  { $self->ebird->region->info( $_->[0]->parent->code ) }
		map  { $self->ebird->region->info( $_->[0]->location_id  ) }
		sort { $a->[1] <=> $b->[1] }
		map  { [ $_, $self->latlong->distance_to($_) ] }
		$data->@*;

	\%d;
	}

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT

Copyright 2023-2026, brian d foy C<< <briandfoy@pobox.com> >>

=cut

__PACKAGE__;
