use v5.38;
use utf8;
no feature qw(module_true);

package eBird::RegionType::World;
use parent qw(eBird::RegionType);

=encoding utf8

=head1 NAME

eBird::RegionType::World - represents the top of the region type true

=head1 SYNOPSIS

You shouldn't need this class at the application level.

	use eBird::RegionType;

	my $region_type = eBird::RegionType->new_world_type;

To test a region type:

	if( $region_type->is_world ) { ... }

=head1 DESCRIPTION

To define relationships between region types, it's easier to have a type
that represents the highest region. For example, the parent class of the
Country class is World, although it does not appear in the region name
(such as C<US-NY-001>).

=head2 Methods

These inherit all the methods from L<eBird::RegionType> and overrides the
ones specific for Null.

=over 4

=item * is_in_name

Returns false always. The World region never shows up in the string for the
region, such as C<US-NY-001>.

=item * is_world

Returns true always.

=item * parent_region_type

Returns L<eBird::RegionType::Null>.

=item * sub_region_type

Returns L<eBird::RegionType::Country>.

=cut


sub is_in_name         { 0 }
sub is_world           { 1 }
sub parent_region_type { 'eBird::RegionType::Null' };
sub sub_region_type    { 'eBird::RegionType::Country' };

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
