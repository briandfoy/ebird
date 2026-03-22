use v5.38;
use utf8;
no feature qw(module_true);

package eBird::RegionType::Subnational1;
use parent qw(eBird::RegionType);

=encoding utf8

=head1 NAME

eBird::RegionType::Subnational1 - represents the middle of the region tree, typically a state or province

=head1 SYNOPSIS

You shouldn't need this class at the application level.

	use eBird::RegionType;

	my $region_type = eBird::RegionType->new_subnational1_type;

To test a region type:

	if( $region_type->is_subnational1 ) { ... }

=head1 DESCRIPTION

This region type represents the division after L<eBird::RegionType::Country>,
which might be a city.

=head2 Methods

These inherit all the methods from L<eBird::RegionType> and overrides the
ones specific for Subnational1.

=over 4

=item * is_subnational1

Returns true always.

=item * parent_region_type

Returns L<eBird::RegionType::Country>.

=item * sub_region_type

Returns L<eBird::RegionType::Subnational2>. Not all actual Subnational1 regions
have defined Subnational2 divisions, but the type doesn't know about that.

=cut

sub is_subnational1    { 1 }
sub sub_region_type    { 'eBird::RegionType::Subnational2' };
sub parent_region_type { 'eBird::RegionType::Country' };

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
