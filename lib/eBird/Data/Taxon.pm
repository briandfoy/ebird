use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Taxon;
use parent qw(eBird::Data::Base);

use namespace::autoclean;
use List::Util qw(first);
use Scalar::Util qw(blessed);

=encoding utf8

=head1 NAME

eBird::Data::Taxon - represents a single bird type (species, subspecies, group)

=head1 SYNOPSIS

These objects are created from the results of the API calls, and you typically
don't need to create them yourselves:



=head1 DESCRIPTION

=head2 Categories

There are several types of taxa:

=over 4

=item * spuh:  a group of species (such as genus) that is not further specified (for example, "Larus sp.")

=item * slash: a species-pair, e.g., Tundra/Trumpeter Swan Cygnus columbianus/buccinator

=item * species: a particular species

=item * issf (Identifiable Sub-specific Group): a species

=item * hybrid: offspring from the mating between two different species

=item * intergrade: hybrid between two ISSF

=item * form: a catch-all category

=back

See L<https://science.ebird.org/en/use-ebird-data/the-ebird-taxonomy>

=head2 Class Methods

=over 4

=item * new_from_code( SPECIES_CODE )

=cut

sub new_from_code ($class, $species_code) {
	bless { species_code => $species_code }, $class;
	}

=back

=head2 Attribute methods

=over 4

=item * banding_codes

Returns the banding code.

=item * category

Returns the category string. See L</Categories>.

=item * com_name_codes

Returns the string that is the concatenation with spaces of all the common
name codes. This is how they appear in the original data.

=item * common_name_codes

Returns the common name codes as an array ref. Some taxa, such as hybrids, will
have multiple codes.

=cut

sub common_name_codes ($self) {
	state $key = 'common_name_codes';
	unless( exists $self->{$key} ) {
		my( $genus, $rest ) = split /\s+/, $self->scientific_name;
		$self->{$key} = do {
			if( $genus =~ /\A[A-Z]/ ) { $genus }
			else { () }
			}
		}

	return $self->{$key};
	}

=item * common_name

=item * extinct

=item * extinct_year

=item * family_com_name

=item * family_common_name

Returns the family common name.

=cut

sub family_common_name ($self) { $self->family_com_name }

=item * family_sci_name

=item * family_scientific_name

Returns the family scientific name.

=cut

sub family_scientific_name ($self) { $self->family_sci_name }

=item * genus

Returns the scientific genus. This is guessed from the original data
by looking in C<scientific_name>.

=cut

sub genus ($self) {
	state $key = 'genus';
	return unless $self->has_genus;

	unless( exists $self->{$key} ) {
		my( $genus, $rest ) = split /\s+/, $self->scientific_name;
		$self->{$key} = do {
			if( $genus =~ /\A[A-Z]/ ) { $genus }
			else { () }
			}
		}

	return $self->{$key};
	}

=item * order

Returns the scientific order.

=item * report_as

Returns a species code to use to combine reports for forms, hybrids, and such
as a particular species.

=item * sci_name_codes

Returns the scientific name codes as a space separated string, which is how
this field appears in the original data.

=item * scientific_name_codes

Returns the scientific name codes as an array ref

=cut

sub scientific_name_codes ($self) {
	return $self->{'scientific_name_codes'} if exists $self->{'scientific_name_codes'};

	$self->{'scientific_name_codes'} = [ split /\s+/, $self->sci_name_codes ];
	}

=item * scientific_name

Returns the scientific name, which might have hybrid or other information.

=item * species_code

Returns the taxa short code, such as C<cangoo> for the Canada Goose.

=item * subspecies

The subspecies is not a separate part of the taxonomy data.  This is
guessed from C<scientific_name>. If there is a genus, and then there are
more than two groups of non-whitespace to the scientific name, this
returns true.

This ignores text after in braces or parens, or text starting with " x ", which
is used for hybrids.

=cut

sub subspecies ($self) {
	state $key = 'subspecies';
	return unless $self->has_genus;

	unless( exists $self->{$key} ) {
		my $name = $self->scientific_name;
		my @parts = split /\s+/, $self->scientific_name =~ s/(?: \[ | \( | \s+ x ) .*//gr;
		$self->{$key} = $parts[-1];
		}

	return $self->{$key};
	}

=item * taxon_order

Returns a number that identifies, and is presumably persistent to a particular
taxa even if the names change.

=back

=head2 Stuff

These return true if the

=over 4

=item * has_genus

Returns true if the category is not a spuh. All others have a genus in the
scientific name.

=cut

sub has_genus ($self) {
	return ! $self->is_spuh;
	}

=item * is_extinct

Returns true if the taxa is considered extinct.

=cut

sub is_extinct ($self) { 0 + !! $self->extinct }

=item * is_form

=cut

sub is_form ($self) { $self->category eq 'form' }

=item * is_hybrid

=cut

sub is_hybrid ($self) { $self->category eq 'hybrid' }

=item * is_intergrade

=cut

sub is_intergrade ($self) { $self->category eq 'intergrade' }

=item * is_issf

=cut

sub is_issf ($self) { $self->category eq 'issf' }

=item * is_slash

=cut

sub is_slash ($self) { $self->category eq 'slash' }

=item * is_species

=cut

sub is_species ($self) { $self->category eq 'species' }

=item * is_spuh

=cut

sub is_spuh ($self) { $self->category eq 'spuh' }

=item * is_subspecies


=cut

sub is_subspecies ($self) {
	0 + !! $self->{'subspecies'}
	}

=back

=head2 Instance methods

We can make an C<eBird::Data::Taxon> object with just a species code, and for
many tasks, this might be sufficient. To get the rest of the information that
eBird reports, we can "inflate" the object.

This does not change the existing object but returns a new one.

=over 4

=item * inflate

=cut

sub inflate ($self, $ebird = eBird->new( io => eBird::IO->new_quiet )) {
	return $self if $self->is_inflated;
	my $taxon =
		first
		{ $_->species_code eq $self->species_code }
		$ebird->taxonomy->taxa->@*;

	foreach my $key ( keys $taxon->%* ) {
		$self->{$key} = $taxon->{$key};
		}

	return $self;
	}

=item * is_inflated

Returns true if we think the taxa has pulled in all details that eBird reports.

=cut

sub is_inflated ($self) {
	return exists $self->{'banding_codes'}
	}

=back

=head1 SEE ALSO


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
