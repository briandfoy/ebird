use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Taxonomy;
use Exporter qw(import);

=encoding utf8

=head1 NAME

eBird::Taxonomy -

=head1 SYNOPSIS


=head1 DESCRITION

=head2 Class Methods

=over 4

=cut


sub _code_matches ( $self, $type, $pattern ) {
	foreach my $key ( keys $self->{$type}->%* ) {
		return 1 if $key =~ /$pattern/i;
		}
	return 0;
	}

=item * banding_code_matches

=cut

sub banding_code_matches ( $self, $pattern ) {
	$self->_code_matches( 'banding_codes', $pattern );
	}

=item * common_name_matches

=cut

sub common_name_matches ( $self, $pattern ) {
	$self->common_name =~ m/$pattern/;
	}

=item * common_name_code_matches

=cut

sub common_name_code_matches ( $self, $pattern ) {
	$self->_code_matches( 'com_name_codes', $pattern );
	}

=item * genus

=cut

sub genus ( $self ) {
	$self->{genus} //= ( split /\s+/, $self->scientific_name )[0];
	}

=item * genus_matches

=cut

sub genus_matches ( $self, $pattern ) {
	$self->genus =~ m/$pattern/;
	}

=item * family

=cut

sub family ( $self ) {
	$self->family_sci_name;
	}

=item * family_matches

=cut

sub family_matches ( $self, $pattern ) {
	$self->family_sci_name =~ m/$pattern/;
	}

=item * order_matches

=cut

sub order_matches ( $self, $pattern ) {
	$self->order =~ m/$pattern/;
	}

=item * species

=cut

sub species ( $self ) {
	$self->{species} //= ( split /\s+/, $self->scientific_name )[1];
	}

=item * species_matches

=cut

sub species_matches ( $self, $pattern ) {
	$self->species =~ m/$pattern/;
	}

=item * subspecies

=cut

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

