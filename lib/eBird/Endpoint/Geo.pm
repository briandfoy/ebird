use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Geo;
use parent qw(eBird::Endpoint::Base);

use namespace::autoclean;
use Carp         qw(carp);
use Ref::Util    qw(is_arrayref);
use Scalar::Util qw(blessed);

=encoding utf8

=head1 NAME

eBird::Endpoint::Geo -

=head1 SYNOPSIS

=head1 DESCRIPTION

# Only subnational2 codes in the United States, New Zealand, or Mexico are currently supported

=over 4

=item * adjacent_regions( COUNTRY, SUBNATIONAL1 )

=cut

sub adjacent_regions ( $self, $region_code ) {
	state $path_template = 'ref/adjacent/{{regionCode}}';
	state $supports_subnational2 = { map { $_, 1 } qw(US MX NZ) };

	$region_code = do {
		if( blessed($region_code) and $region_code->can('code') ) {
			$region_code->code;
			}
		elsif( is_arrayref($region_code) ) {
			join '-', $region_code->@*;
			}
		else {
			$region_code
			}
		};

	$self->ebird->get(
		args => {
			regionCode => $region_code,
			},
		bless_into    => 'eBird::Data::Region',
		cache_key     => "adjacent_regions-$region_code",
		path_template => $path_template,
		);
	}

=item * name

Returns the name of the method used for L<eBird> to access this part of the
API.

=cut

sub name ($self) { 'geo' }

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


