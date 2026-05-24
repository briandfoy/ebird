use v5.38;
use utf8;
no feature qw(module_true);

package  eBird::Endpoint::Observation;
use parent qw(eBird::Endpoint::Base);

=encoding utf8

=head1 NAME

eBird::Endpoint::Observation - endpoints related to observations

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item * historic_in_region_on_date

=cut

=begin comment

Name                Values                  Default	Description
-----------------------------------------------------------------------------------------------------------
back                1-30                    14      The number of days back to fetch observations.
cat                 any available category  (all)   Only fetch observations from these taxonomic categories.
hotspot             true, false             false   Only fetch observations from hotspots.
includeProvisional  true, false             false   Include observations which have not yet been reviewed.
maxResults          1-10000                 (all)   Only fetch this number of observations.
r                   any location code       (none)  Fetch observations from up to 10 locations.
sppLocale           any available locale    en      Use this language for species common names.

=end comment

=cut

sub historic_in_region_on_date ( $self, $region_code, $date ) {
	my $path_template = 'data/obs/{{regionCode}}/historic/{{y}}/{{m}}/{{d}}';
my( $year, $month, $day );
	$self->ebird->get(
		args => {
			regionCode => $region_code,
			'y' => $year,
			'm' => $month,
			'd' => $day,
			},
		bless_into    => 'eBird::Data::Observation',
		path_template => $path_template,
		);

	}

=begin comment

Name                Values                  Default	Description
-----------------------------------------------------------------------------------------------------------
back	            1-30	                  14	The number of days back to fetch observations.
cat	                any available category	(all)	Only fetch observations from these taxonomic categories.
hotspot	            true, false             false	Only fetch observations from hotspots.
includeProvisional	true, false	            false	Include observations which have not yet been reviewed.
maxResults	        1-10000	                (all)	Only fetch this number of observations.
r	                any location code       (none)	Fetch observations from up to 10 locations.
sppLocale	        any available locale	en	    Use this language for species common names.

=end comment

=cut

=item * recent_in_region

=cut

sub recent_in_region ($self, $region) {
	my $path_template = 'data/obs/{{regionCode}}/recent';

	$self->ebird->get(
		args => {
			regionCode => $region->code,
			},
		bless_into    => 'eBird::Data::Observation',
		path_template => $path_template,
		);
	}

=begin comment

Name                Values                  Default	Description
-----------------------------------------------------------------------------------------------------------
back                1-30                    14     The number of days back to fetch observations.
cat                 any available category  (all)  Only fetch observations from these taxonomic categories.
dist *              0 - 50                  25     The search radius from the given position, in kilometers.
hotspot             true, false             false  Only fetch observations from hotspots.
includeProvisional  true, false             false  Include observations which have not yet been reviewed.
lat                 -90 - 90                       Required. Latitude to 2 decimal places.
lng                 -180 - 180                     Required. Longitude to 2 decimal places.
maxResults          1-10000                 (all)  Only fetch this number of observations.
sort *              date, species           date   Sort observations by taxonomy or by date, most recent first.
sppLocale           any available locale    en     Use this language for species common names.

=end comment

=cut

=item * recent_nearby

=cut

sub recent_nearby ($self, $geo, $query) {
	my $path_template = 'data/obs/geo/recent';

	$self->ebird->get(
		args => {},
		bless_into    => 'eBird::Data::Observation',
		path_template => $path_template,
		query         => {
			lat => $geo->lat,
			lng => $geo->long,
			},
		);
	}

=begin comment

Name        Values               Default	Description
-----------------------------------------------------------------------------------------------------------
back        1-30                  14     The number of days back to fetch observations.
detail *    simple, full          simple  Include a subset (simple), or all (full), of the fields available.
dist *       0 - 50                25     The search radius from the given position, in kilometers.
hotspot     true, false           false  Only fetch observations from hotspots.
lat         -90 - 90                     Required. Latitude to 2 decimal places.
lng         -180 - 180                   Required. Longitude to 2 decimal places.
maxResults  1-10000               (all)  Only fetch this number of observations.
sppLocale   any available locale  en     Use this language for species common names.

=end comment

=cut

=item * recent_nearby_notable_species

=cut

sub recent_nearby_notable_species ($self, $geo) {
	my $path_template = 'data/obs/geo/recent/notable';

	$self->ebird->get(
		args => {},
		bless_into    => 'eBird::Data::Observation',
		path_template => $path_template,
		query         => {
			lat  => $geo->lat,
			long => $geo->long,
			},
		);
	}

=begin comment

Name                Values                Default	Description
-----------------------------------------------------------------------------------------------------------
back                1-30                  14     The number of days back to fetch observations.
dist                0 - 50                25     The search radius from the given position, in kilometers.
hotspot             true, false           false  Only fetch observations from hotspots.
includeProvisional  true, false           false  Include observations which have not yet been reviewed.
lat                 -90 - 90                     Required. Latitude to 2 decimal places.
lng                 -180 - 180                   Required. Longitude to 2 decimal places.
maxResults          1-10000               (all)  Only fetch this number of observations.
sppLocale           any available locale  en     Use this language for species common names.

=end comment

=cut

=item * recent_nearby_species

=cut

sub recent_nearby_species ($self, $geo, $species) {
	my $path_template = 'data/obs/geo/recent/{{speciesCode}}';

	$self->ebird->get(
		args => {
			speciesCode => $species->code,
			},
		bless_into    => 'eBird::Data::Observation',
		path_template => $path_template,
		query         => {
			lat  => $geo->lat,
			long => $geo->long,
			},
		);
	}

=begin comment

Name       Values                Default Description
-----------------------------------------------------------------------------------------------------------
back        1-30                  14     The number of days back to fetch observations.
detail *    simple, full          simple  Include a subset (simple), or all (full), of the fields available.
dist        0 - 50                25     The search radius from the given position, in kilometers.
hotspot     true, false           false  Only fetch observations from hotspots.
lat         -90 - 90                     Required. Latitude to 2 decimal places.
lng         -180 - 180                   Required. Longitude to 2 decimal places.
maxResults  1-10000               (all)  Only fetch this number of observations.
sppLocale   any available locale  en     Use this language for species common names

=end comment

=cut

=item * recent_notable_in_region

=cut

sub recent_notable_in_region ($self, $region) {
	my $path_template = 'data/obs/{{regionCode}}/recent/notable';

	$self->ebird->get(
		args => {
			regionCode => $region->code,
			},
		bless_into    => 'eBird::Data::Observation',
		cache_key     => "adjacent_regions-" . $region->code,
		path_template => $path_template,
		);
	}

=begin comment

Name                Values                Default Description
-----------------------------------------------------------------------------------------------------------
back                1-30                  14     The number of days back to fetch observations.
hotspot             true, false           false  Only fetch observations from hotspots.
includeProvisional  true, false           false  Include observations which have not yet been reviewed.
lat                 -90 - 90                     Required. Latitude to 2 decimal places.
lng                 -180 - 180                   Required. Longitude to 2 decimal places.
maxResults          1-3000                3000   Only fetch up to this number of observations.
sppLocale           any available locale  en     Use this language for species common names.
dist                0-50                  (all)  Only fetch observations within this distance of the provided lat/lng

=end comment

=cut

=item * nearest_species

=cut

sub nearest_species ($self, $geo, $species) {
	my $path_template = 'data/nearest/geo/recent/{{speciesCode}}';

	$self->ebird->get(
		args => {
			speciesCode => $species->code,
			},
		bless_into    => 'eBird::Data::Observation',
		cache_key     => "adjacent_regions-" . $species->code,
		path_template => $path_template,
		required      => [ qw(lat long) ],
		query         => {
			lat  => $geo->lat,
			long => $geo->long,
			},
		);
	}

=begin comment

Name                Values                Default Description
-----------------------------------------------------------------------------------------------------------
back                1-30                  14      The number of days back to fetch observations.
hotspot             true, false           false   Only fetch observations from hotspots.
includeProvisional  true, false           false   Include observations which have not yet been reviewed.
maxResults          1-10000               (all)   Only fetch this number of observations.
r  *                 any location code     (none)  Fetch observations from up to 10 locations.
sppLocale           any available locale  en      Use this language for species common names.


=end comment

=cut

=item * recent_species_in_region

=cut

sub recent_species_in_region ($self, $region, $species) {
	my $path_template = 'data/obs/{{regionCode}}/recent/{{speciesCode}}';

	$self->ebird->get(
		args => {
			regionCode  => $region->code,
			speciesCode => $species->code,
			},
		bless_into    => 'eBird::Data::Observation',
		path_template => $path_template,
		required      => [],
		validate      => {},
		);
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


