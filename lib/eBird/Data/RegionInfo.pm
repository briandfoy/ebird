use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::RegionInfo;
use parent qw(Hash::AsObject);

use eBird;
use eBird::RegionType;

=encoding utf8

=head1 NAME

eBird::Data::RegionInfo - the representation of region information

=head1 SYNOPSIS

	my $countries = $eBird->region->countries;
	foreach my $c ( $countries->@* ) {
		printf "%2s  -->  %s\n", $c->short_code, $c->name;
		}

=head1 DESCRIPTION

These objects represent the information eBird tracks about a region.

=over 4

=item * adjacent_regions

Retrieves the regions that touch this region.

=cut

sub adjacent_regions ($self) {
	eBird->new->geo->adjacent_regions( $self->code );
	}

=item * label

=cut

sub label ($self) { $self->result }

=item * region

=cut

sub region ($self) { $self->code }

=item * type

Returns an L<eBird::RegionType> object.

=cut

sub type ($self) {
	eBird::RegionType->new_for( $self->{'type'} );
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

__END__

bless( {
  "bounds" => {
    "maxX" => "179.773408",
    "maxY" => "71.390685",
    "minX" => "-179.150558",
    "minY" => "18.909858"
  },
  "code" => "US",
  "latitude" => "45.1502715",
  "longitude" => "0.311425",
  "result" => "United States",
  "type" => "country"
}, 'eBird::Data::RegionInfo' )
