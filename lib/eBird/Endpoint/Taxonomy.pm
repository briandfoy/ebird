use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Taxonomy;
use parent qw(eBird::Endpoint::Base);

use namespace::autoclean;
use eBird::Util qw();

=encoding utf8

=head1 NAME

eBird::Endpoint::Taxonomy -

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_locale

=cut

sub default_locale { 'en' }

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

=item * parse_taxonomy_csv

Calls C<parse_csv> from L<eBird::Util> with the appropriate settings.

=cut

sub parse_taxonomy_csv ($self, $csv_data) {
	state $headers = [
		qw(
			scientific_name common_name species_code category taxon_order
			com_name_codes sci_name_codes banding_codes order family_com_name
			family_sci_name report_as extinct extinct_year
		)
		];

	eBird::Util::parse_csv( $csv_data, $headers, 'eBird::Data::Taxon' );
	}

=item * taxa(ARGS)

Loads the latest version of the taxonomy data for the locale of the L<eBird>
object this object is using.

=cut

sub taxa ( $self, %args ) {
	my %query;
	$query{'format'}    = 'csv';
	$query{'version'}   = $self->latest_version,
	$query{'locale'}    = $args{'locale'} // $self->ebird->locale;

	my $data = $self->ebird->get(
		args          => {},
		bless_into    => 'eBird::Data::Base',
		cache_key     => $self->taxa_cache_file( @query{qw(locale version)} ),
		json          => 0,
		path_template => 'ref/taxonomy/ebird',
		query         => \%query,
		);

	$self->parse_taxonomy_csv($data);
	}

=item * taxa_cache_file()

=cut

sub taxa_cache_file ($self, $locale = $self->default_locale, $version = $self->latest_version ) {
	join '-', 'taxonomy', $locale, $version;
	}

=item * taxa_for_species( SPECIES_CODES )

Not yet implemented.

=cut

sub taxa_for_species( $self, @species ) {
	$self->ebird->io->carp( "taxa_for_species not yet implemented" );
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
