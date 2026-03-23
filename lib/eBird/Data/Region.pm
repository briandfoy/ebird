use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Region;
use parent qw(eBird::Data::Base);

use eBird;

=encoding utf8

=head1 NAME

eBird::Data::Region - the representation of region specification

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the information eBird tracks about a region.

=over 4

=item * adjacent_regions

Returns the adjacent regions for the region

=item * code

The short form of the region

=item * info

Returns the L<eBird::Data::RegionInfo> for this region.

=item * label

=item * name

The long name.

=item * region

The same thing as C<code>

=cut

sub adjacent_regions ($self) {
	eBird->new->geo->adjacent_regions($self->code);
	}

sub code  ($self) { $self->{'code'} }

sub info ($self) {
	eBird->new->region->region_info_for($self->code);
	}

sub label ($self)  { $self->name }

sub region ($self) { $self->code }

=back

=head2 Tests

=over 4

=item * is_country

Returns true if the region is a country (the code has no dashes).

=item * is_subnational1

Returns true if the region is at the subnational1 (the code has one dash).

=item * is_subnational2

Returns true if the region is a subnational2 (the code has two dashes).

=item * is_world

Returns false, always

=cut

sub is_country      ($self) { length $self->code and 0 == $self->code =~ tr/-/-/ }
sub is_subnational1 ($self) { 1 == $self->code =~ tr/-/-/ }
sub is_subnational2 ($self) { 2 == $self->code =~ tr/-/-/ }
sub is_world        ($self) { 0      }

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
