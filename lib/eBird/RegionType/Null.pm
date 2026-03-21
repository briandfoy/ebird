use v5.36;
use utf8;

package eBird::RegionType::Null;
use parent qw(eBird::RegionType);

=encoding utf8

=head1 NAME

eBird::RegionType::Null - represents the state of something not being a region type

=head1 SYNOPSIS

You shouldn't need this class at the application level.

	use eBird::RegionType;

	my $country_region_type = eBird::RegionType->new_country_type;

To test a region type:

	if( $region_type->is_country ) { ... }

=head1 DESCRIPTION

To define relationships between region types, it's easier to have a type
that represents the null or "no region" idea. For example,s the parent
class of the World type is Null, and the sub region of Subnational2 is
is Null. This removes special cases.

=head2 Methods

These inherit all the methods from L<eBird::RegionType> and overrides the
ones specific for Null.

=over 4

=item * is_in_name

Returns false always. This region never shows up in the string for the
region, such as C<US-NY-001>.

=item * is_null

Returns true always.

=item * is_type

Returns false always, while all other types return true.

=cut


sub is_in_name     { 0 }
sub is_null        { 1 }
sub is_type        { 0 }

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
