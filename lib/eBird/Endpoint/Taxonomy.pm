use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Taxonomy;
use parent qw(eBird::Endpoint::Base);

use namespace::autoclean;

=encoding utf8

=head1 NAME

eBird::Endpoint::Taxonomy -

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * ebird_groups

This calls C<groups> for the C<ebird> set.

=cut

sub ebird_groups ($self) {
	$self->groups('ebird');
	}


=item * forms( SPECIES_CODE )

=cut

# combined taxa have a report_as to point to the main one
sub forms ( $self, $species_code ) {
	$self->ebird->get(
		args => {
			species_code => $species_code,
			},
		cache_key     => "forms-$species_code",
		path_template => 'ref/taxon/forms/{{species_code}}',
		);
	}

=item * groups( GROUPING )

Return the species group for C<GROUPING>, which is either C<ebird> or C<merlin>.

=cut

sub groups ($self, $species_group = 'ebird') {
	my $namespace = $species_group eq 'ebird' ? 'eBird' : ucfirst(lc($species_group));

	my $data = $self->ebird->get(
		args          => {
			speciesGrouping => $species_group
			},
		bless_into    => sprintf('eBird::Data::%sSpeciesGroup', $namespace),
		cache_key     => 'species-group-' . $species_group,
		path_template => 'ref/sppgroup/{{speciesGrouping}}',
		);
	}

=item * latest_version

Returns the version string of the latest taxonomy version

=cut

sub latest_version ($self) {
	my( $latest ) =
		map  { $_->version }
		grep { $_->is_latest }
		$self->versions->@*;

	$latest;
	}

=item * locale_codes

=cut

sub locale_codes ( $self ) {
	my $data = $self->ebird->get(
		args          => {},
		bless_into    => "eBird::Data::LocaleCode",
		cache_key     => "taxa-locale-codes",
		path_template => 'ref/taxa-locales/ebird',
		);
	}

=item * merlin_groups

This calls C<groups> for the C<merlin> set.

=cut

sub merlin_groups ($self) {
	$self->groups('merlin');
	}

=item * taxa

=cut

sub taxa ( $self, %query ) {
	$query{'format'}    = 'csv';
	$query{'version'}   = $self->latest_version,
	$query{'locale'}  //= 'en';

	my $data = $self->ebird->get(
		args          => {},
		bless_into    => 'eBird::Data::Base',
		cache_key     => "taxonomy-$query{'locale'}-$query{'version'}",
		json          => 0,
		path_template => 'ref/taxonomy/ebird',
		query         => \%query,
		);

	$self->ebird->parse_taxonomy_csv( $data );
	}

=item * versions

Fetches all of the taxonomy versions

=cut

sub versions ( $self ) {
	my $data = $self->ebird->get(
		args          => {},
		bless_into    => 'eBird::Data::TaxonomyVersion',
		cache_key     => 'versions',
		path_template => 'ref/taxonomy/versions',
		);
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
