use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Region;
use Exporter qw(import);

use B;
use Carp;

our @EXPORT;
our @EXPORT_OK;
our %EXPORT_TAGS;

sub MODIFY_CODE_ATTRIBUTES ( $package, $code_ref, @attributes ) {
	my( $sub_name ) = B::svref_2object( $code_ref )->GV->NAME;

	my @bad_attributes = ();
	foreach my $attribute ( @attributes ) {
		my( $attribute_name ) = map { uc() } $attribute =~ m/\A(\w+)/;
		no strict 'refs';
		if( ! defined &{"ATTRIBUTE_$attribute_name"} ) {
			push @bad_attributes, $attribute if &{"ATTRIBUTE_$attribute_name"}( $package, $code_ref, $attribute )
			}
		else {
			&{"ATTRIBUTE_$attribute_name"}( $package, $code_ref, $attribute )
			}
		}

	@bad_attributes;
	}

sub ATTRIBUTE_EXPORT ( $package, $code_ref, $attribute ) {
	my( $sub_name ) = B::svref_2object( $code_ref )->GV->NAME;
	$sub_name =~ s/.*:://;

	push @EXPORT_OK, $sub_name;
	push $EXPORT_TAGS{'all'}->@*, $sub_name;

	return;
	}

=encoding utf8

=head1 NAME

eBird::Region -

=head1 SYNOPSIS

	package eBird;
	use eBird::Region qw(:all);

=head1 DESCRITION

=over 4

=item * adjacent_regions(REGION)

Returns an array ref of L<eBird::Region> objects for the regions that touch
C<REGION>.

=cut

sub adjacent_regions :Export ($ebird, $region) {
	$ebird->geo->adjacent_regions( $region );
	}

=item * country_from_code( CODE )

Returns the L<eBird::Data::Country> for C<CODE>, or the empty list if
there is no country for C<CODE>. This is case insensitive.

=cut

sub country_from_code :Export ( $ebird, $code ) {
	my $country =
		List::Util::first
		{ lc $_->code eq lc $code }
		$ebird->region->countries->@*;

	defined $country ? $country : ();
	}

=item * country_from_name( NAME )

Returns the L<eBird::Data::Country> for C<NAME>, or the empty list if
there is no country for C<NAME>. This is case insensitive.

=cut

sub country_from_name :Export ( $ebird, $name ) {
	my $country =
		List::Util::first
		{ lc $_->name eq lc $name }
		$ebird->region->countries->@*;

	defined $country ? $country : ();
	}

=item * is_known_country_code

Returns true if C<CODE> is a known country code, and false otherwise.

=cut

sub is_known_country_code :Export ( $self, $code ) {
	defined $self->country_from_code($code);
	}

=item * is_known_country_name

Returns true if C<NAME> is a known country name, and false otherwise.

=cut

sub is_known_country_name :Export ( $self, $code ) {
	defined $self->country_from_name($code);
	}

=item * is_valid_parent_region_type(TYPE)

Returns true if C<TYPE> is a known parent region type. See C<parent_region_types>.

=cut

sub is_valid_parent_region_type :Export ( $self, $type ) {
	state %valids = map { $_, 1 } $self->parent_region_types->@*;
	exists $valids{$type};
	}

=item * is_valid_region(REGION)

Returns true if C<REGION> looks like it could be a region code. This does not
mean that the string is an actual region.

=cut

sub is_valid_region ( $self, $region ) {
	$region =~ m/\A
		[A-Z]+
		(
			(- [A-Z]+)
			(- \d+ )?
		)?
		\z
		/xa;
	}

=item * is_valid_region_type(TYPE)

Returns true if C<TYPE> is a known region type. See <region_types>.

=cut

sub is_valid_region_type  :Export ( $self, $type ) {
	state %valids = map { $_, 1 } $self->region_types;
	exists $valids{$type};
	}

=item * parent_region_types

Returns the list of region types that can be parents: C<world>,
C<country>, and C<subnational1>. These are the region divisions that have
smaller units (so, all of them except C<subnational2>).

=cut

sub parent_region_types :Export ( $self ) {
	qw(world country subnational1);
	}

=item * region_types

Returns the list of region type strings, which are C<country>, C<subnational1>,
and C<subnational2>.

=cut

sub region_types :Export ( $self ) {
	qw(country subnational1 subnational2);
	}

=item * subregion_data

=cut

sub subregion_data :Export ( $self, $region = undef ) {
	my @parts = split /-/, $region;
	$self->logger->debug( "subregion_data: parts are <@parts>" );

	my $hash = do {
		   if( 0 == @parts ) { $self->countries }
		elsif( 1 == @parts ) { $self->subnationals_for_country(@parts) }
		elsif( 2 == @parts ) { $self->subnationals2_for_country_subnational(@parts) }
		elsif( 3 == @parts ) {
			my %hash = map { $_->id, $_->name } $self->hotspots_in_region( @parts )->@*;
			\%hash;
			}
		};
	}

=item * sub_region_list_for( TYPE, PARENT_REGION )

=cut

sub sub_region_list_for :Export ( $self, $region_type, $parent_region ) {
	unless( $self->invalid_region_result( $region_type ) ) {
		carp "";
		return;
		}

	$self->region->foo;
	}

=item * subnationals2_for_country_subnational

=cut

sub subnationals2_for_country_subnational :Export ( $self, $country, $subnational ) {
	state $path_template = 'ref/region/list/subnational2/{{ country }}-{{ subnational }}';
	my $cache_key = "subnational2-$country-$subnational";

	my $data = $self->get(
		path_template => $path_template,
		cache_key => $cache_key,
		args => {
			country => $country,
			subnational => $subnational,
			},
		);

	return {
		map { ( $_->{code} => $_->{name} ) } $data->@*
		}
	}

=item * subnationals_for_country

=cut

sub subnationals_for_country :Export ( $self, $country ) {
	state $path_template = 'ref/region/list/subnational1/{{ country }}';
	my $cache_key = "subnational-$country";

	my $data = $self->get(
		path_template => $path_template,
		cache_key => $cache_key,
		args => {
			country => $country,
			},
		);

	$data = {
		map { ( $_->{code} => $_->{name} ) } $data->@*
		}
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
