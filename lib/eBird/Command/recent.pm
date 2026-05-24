use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Command::recent;
use parent qw(eBird::Command);

use namespace::autoclean;
use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::recent - show recent sightings of a species in a region

=head1 SYNOPSIS

List results for recent sightings of a species in a region:

	% ebird recent REGION SPECIES

For a Hermit Thrush in Vermont:

	% ebird recent US-VT CAGU


=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<list>.

=cut

sub default_action { 'list' }

=item * default_format

The default format for each observation in the C<list> action. See
L<eBird::Data::Observation> for details.

=cut

sub default_format { '%d %L (%g)' }

=item * description

=cut

sub description ( $self ) {
	"Recent reports of a species in a region"
	}

=item * fallthrough_action()

=cut

sub fallthrough_action ( $self ) { 'fallthrough' }

=back

=head2 Actions

=item * action_kml( SPECIES_CODE, REGION_CODE )

=cut

sub action_kml ( $self, $species, $region ) {
	state $kml_header = <<~"KML";
		<?xml version="1.0" encoding="UTF-8"?>
		<kml xmlns="http://www.opengis.net/kml/2.2">
		<Document>
		KML

	state $kml_footer = <<~"KML";
		</Document>
		</kml>
		KML

	state $format = '%k';

	if( defined $region and ! looks_like_region($region) ) {
		$self->cli->ebird->io->error( "$region does not look like a region" );
		return;
		}

	my $observations = $self->cli->ebird->observation->recent_species_in_region( $region, $species );
	return unless $observations->@*;

	$self->cli->ebird->io->output( $kml_header );

	foreach my $obs ( $observations->@* ) {
		my $line = $obs->format( $format );
		$self->cli->ebird->io->output( $line ) if length $line;
		}

	$self->cli->ebird->io->output( $kml_footer )
	}

=item * action_list( SPECIES_CODE, REGION_CODE )

=cut

sub action_list ( $self, $species, $region, $format = $self->default_format ) {
	if( defined $region and ! looks_like_region($region) ) {
		$self->cli->ebird->io->error( "$region does not look like a region" );
		return;
		}

	my $observations = $self->cli->ebird->observation->recent_species_in_region( $region, $species );
	$self->cli->ebird->logger->debug( sprintf "There are %d observations for <%s> in <%s>", scalar $observations->@*, $species, $region );
	unless( $observations->@* ) {
		$self->cli->ebird->io->error( "No observations for <$species> in <$region>" );
		return;
		}

	foreach my $obs ( $observations->@* ) {
		my $line = $obs->format( $format );
		$self->cli->ebird->io->output( $line ) if length $line;
		}
	}

=back

=head1 TO DO


=head1 SEE ALSO

=over 4

=item * eBird terms of use - https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=item * eBird API - https://documenter.getpostman.com/view/664302/S1ENwy59

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

my $last = __PACKAGE__;

__DATA__

@@ help.txt
This is the DATA section help text.
