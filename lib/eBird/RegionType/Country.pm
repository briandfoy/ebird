use v5.36;
use utf8;

package eBird::RegionType::Country;
use parent qw(eBird::RegionType);

=encoding utf8

=head1 NAME

eBird::RegionType::Country - represents the Country region type

=head1 SYNOPSIS

You shouldn't need this class at the application level.

	use eBird::RegionType;

	my $country_region_type = eBird::RegionType->new_country_type;

To test a region type:

	if( $region_type->is_country ) { ... }

=head1 DESCRIPTION

These inherit all the methods from L<eBird::RegionType> and overrides the
ones specific for countries. This code takes no position on what a country
is or should be called. eBird uses particular divisions and names, and this
code does not have any opinion on what those and their relationships should
be.

=head2 Methods

=over 4

=item * is_country

Overrides the abstract class to return true always.

=cut

sub is_country         { 1 }

=item * parent_region_type

Returns L<eBird::RegionType::World>.

=cut

sub parent_region_type { 'eBird::RegionType::World' };

=item * sub_region_type

Returns L<eBird::RegionType::Subnational1>.

=cut

sub sub_region_type    { 'eBird::RegionType::Subnational1' };

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

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
