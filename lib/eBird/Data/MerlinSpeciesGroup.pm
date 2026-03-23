use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::MerlinSpeciesGroup;
use parent qw(eBird::Data::Base);

=encoding utf8

=head1 NAME

eBird::Data::MerlinSpeciesGroup -

=head1 SYNOPSIS


=head1 DESCRIPTION


=over 4

=item * name

=cut

sub name ($self) { $self->groupName }

=item * order

=cut

sub order ($self) { $self->groupOrder }

=item * type

Returns C<merlin>.

=cut

sub type ($self) { 'merlin' }

=back

=head1 SEE ALSO

=over 4

=item * L<eBird::Data::eBirdSpeciesGroup>

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
