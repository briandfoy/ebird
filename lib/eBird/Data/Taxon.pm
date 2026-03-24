use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Taxon;
use parent qw(eBird::Data::Base);

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
