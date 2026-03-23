use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Taxonomy;
use parent qw(eBird::Endpoint::Base);

use namespace::autoclean;

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item *

=cut


sub _code_matches ( $self, $type, $pattern ) {
	foreach my $key ( keys $self->{$type}->%* ) {
		return true if $key =~ /$pattern/i;
		}
	return false;
	}

sub banding_code_matches ( $self, $pattern ) {
	$self->_code_matches( 'banding_codes', $pattern );
	}

sub common_name_matches ( $self, $pattern ) {
	$self->common_name =~ m/$pattern/;
	}

sub common_name_code_matches ( $self, $pattern ) {
	$self->_code_matches( 'com_name_codes', $pattern );
	}

sub genus ( $self ) {
	$self->{genus} //= ( split /\s+/, $self->scientific_name )[0];
	}

sub genus_matches ( $self, $pattern ) {
	$self->genus =~ m/$pattern/;
	}

sub family ( $self ) {
	$self->family_sci_name;
	}

sub family_matches ( $self, $pattern ) {
	$self->family_sci_name =~ m/$pattern/;
	}

sub order_matches ( $self, $pattern ) {
	$self->order =~ m/$pattern/;
	}

sub species ( $self ) {
	$self->{species} //= ( split /\s+/, $self->scientific_name )[1];
	}

sub species_matches ( $self, $pattern ) {
	$self->species =~ m/$pattern/;
	}

sub subspecies ( $self ) {
	$self->{subspecies} //= ( split /\s+/, $self->scientific_name )[2];
	return defined $self->{subspecies} ? $self->{subspecies} : ();
	}

=back

=head2 Taxonomy

=over 4

=item * species_code_to_common_name

=cut

sub species_code_to_common_name ( $self, $species_code ) {
	state $index = do {
		my $taxonomy = $self->taxonomy;
		my %results;
		foreach my $item ( $self->taxonomy->@* ) {
			$results{$item->species_code} = $item;
			}

		\%results;
		};

	$self->logger->debug( "species_code_to_common_name: $species_code" );

	eval { $index->{$species_code}->common_name } // $species_code;
	}


=item * taxonomy

=cut

sub taxonomy ( $self, %query ) {
	state $path_template = 'ref/taxonomy/ebird';
	state $format = 'csv';

	$query{locale}  //= 'en';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "taxonomy-$query{locale}",
		query         => \%query,
		json          => false,
		);

	$self->parse_taxonomy_csv( $data );
	}

sub _taxonomy_by ( $self, $method, $substring ) {
	my $taxonomy = $self->taxonomy;

	my @results;
	foreach my $item ( $taxonomy->@* ) {
		next unless $item->$method( $substring );
		push @results, $item;
		}

	return \@results;
	}

=item * taxonomy_by_band( BAND_SUBSTRING )

=cut

sub taxonomy_by_band ( $self, $pattern ) {
	$self->_taxonomy_by( 'banding_code_matches', $pattern );
	}

=item * taxonomy_by_common_name( BAND_SUBSTRING )

=cut

sub taxonomy_by_common_name ( $self, $pattern ) {
	$self->_taxonomy_by( 'common_name_matches', $pattern );
	}

=item * taxonomy_by_family( BAND_SUBSTRING )

=cut

sub taxonomy_by_family ( $self, $pattern ) {
	$self->_taxonomy_by( 'family_matches', $pattern );
	}

=item * taxonomy_by_genus( BAND_SUBSTRING )

=cut

sub taxonomy_by_genus ( $self, $pattern ) {
	$self->_taxonomy_by( 'genus_matches', $pattern );
	}

=item * taxonomy_by_order( BAND_SUBSTRING )

=cut

sub taxonomy_by_order ( $self, $pattern ) {
	$self->_taxonomy_by( 'order_matches', $pattern );
	}

=item * taxonomy_all_bands()

=cut

sub taxonomy_all_bands ( $self ) {
	my $taxonomy = $self->taxonomy;

	my %results;
	foreach my $item ( $taxonomy->@* ) {
		$results{$_} = $item for keys $item->{banding_codes}->%*;
		}

	return \%results;
	}

=item * forms

=cut

sub forms ( $self, $species_code ) {
	state $path_template = 'ref/taxon/forms/{{species_code}}';

	$self->get(
		path_template => $path_template,
		cache_key => "forms-$species_code",
		args => {
			species_code => $species_code,
			},
		);
	}

=item * taxa_locales

=cut

sub taxa_locales ( $self ) {
	state $path_template = 'ref/taxa-locales/ebird';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "locales",
		args => {},
		);

	my %hash;
	foreach my $locale ( $data->@* ) {
		$hash{ $locale->{code} } = $locale;
		}

	return \%hash;
	}

=item * taxa_versions

=cut

sub taxa_versions ( $self ) {
	state $path_template = 'ref/taxonomy/versions';

	my $data = $self->get(
		args          => {}
		bless_into    => 'eBird::Data::TaxonomyVersion',
		cache_key     => 'versions',
		path_template => $path_template,
		json          => 0,
		);
	}

=item * taxa_groups

=cut

sub taxa_groups ( $self, %raw_args ) {
	state $path_template = 'ref/sppgroup/{{grouping}}';
	state @locales = qw(
		bg cs da de en es es_AR es_CL es_CU es_ES es_MX es_PA fr he
		is nl no pt_BR pt_PT ru sr th tr zh
		);
	state @groupings = qw(merlin ebird);

	my %defaults = qw( grouping ebird );

	my %args = ( qw(grouping ebird), %raw_args{qw(grouping)} );
	my %query;
	$query{'groupNameLocale'} = $raw_args{'locale'} // 'en';

	$self->get(
		path_template => $path_template,
		cache_key => "groups-$query{'groupNameLocale'}-$args{'grouping'}",
		args  => \%args,
		query => \%query,
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
