use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Region;
use parent qw(eBird::Endpoint::Base);

=encoding utf8

=head1 NAME

eBird::Endpoint::Region - handles the queries to ref/region

=head1 SYNOPSIS

=head1 DESCRITION

=head2 Class
=head2 Region

=over 4

=item * countries

Returns a list of all the countries eBird recognizes as an array reference
of L<eBird::Data::Country> objects.

=cut

sub countries ( $self ) {
	state $path_template = 'ref/region/list/country/world';
	state $cache_key = 'countries';

	$self->ebird->get(
		bless_into    => 'eBird::Data::Country',
		cache_key     => $cache_key,
		path_template => $path_template,
		);
	}

=item * info( REGION | LOCATION_ID )

The major region, country, subnational1 or subnational2 code, or locId

=cut

sub info ( $self, $region ) {
	state $path_template = 'ref/region/info/{{region}}';

	my $bless_into = do {
		if( $region =~ /\AL/ ) { 'LocationInfo' }
		else                   { 'RegionInfo'   }
		};

	$self->ebird->get(
		args => {
			region => $region,
			},
		bless_into    => 'eBird::Data::' . $bless_into,
		cache_key     => 'region-info-' . $region,
		path_template => $path_template,
		);
	}

=item * subregion_list_for( REGION_TYPE, PARENT_REGION_CODE )

C<REGION_TYPE> is

C<PARENT_REGION_CODE> is

The major region, country, subnational1 or subnational2 code, or locId

=cut

sub subregion_list_for ( $self, $region_type, $parent_region_code ) {
	state $path_template = 'ref/region/list/{{regionType}}/{{parentRegionCode}}';

	$self->ebird->get(
		path_template => $path_template,
		args => {
			regionType       => $region_type,
			parentRegionCode => $parent_region_code,
			},
		bless_into    => 'eBird::Data::Region',
		cache_key     => join '-', 'subregion', 'list', $region_type, $parent_region_code,
		path_template => $path_template,
		);
	}

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

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
