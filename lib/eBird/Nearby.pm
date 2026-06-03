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



=item * closest(LATLONG)

Returns the region for the L<eBird::Nearby> object.

This isn't something that the eBird API supplies directly, so we guess a little
by looking for

=cut

sub closest ($class, $latlong, $dist = 32) {
	my $ebird = eBird->new;
	my $data = $ebird->hotspot->nearby( $latlong, { dist => $dist });

	my @d =
		grep { $_->latlong_box->contains($latlong) }
		map  { $ebird->region->info( $_->[0]->location_id  ) }
		sort { $a->[1] <=> $b->[1] }
		map  { [ $_, $latlong->distance_to($_->latlong) ] }
		$data->locations->@*;

	$d[0];
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
