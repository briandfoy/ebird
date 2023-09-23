use v5.36;
use experimental qw(signatures);

package eBird;
use strict;

use warnings;
no warnings;

our $VERSION = '0.001_01';

use Carp;
use Mojo::Util qw(dumper);

=encoding utf8

=head1 NAME

eBird - Access to the eBird API

=head1 SYNOPSIS

	use eBird;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub new ( $class, %args ) {
	state %defaults = (
		api_base_url => 'https://api.ebird.org/v2',
		);
	state %allowed = map { $_, 1 } qw(
		api_key
		);

	$args{api_key} //= $ENV{EBIRD_API_KEY};

	my $self = bless {
		%defaults,
		map { $_, $args{$_} } grep { $allowed{$_} } keys %args,
		}, $class;

	$self->_setup_ua();
	return $self;
	}

=back

=head2 Instance methods

=over 4


=back

=cut

sub api_base_url ( $self ) { $self->{api_base_url} // 'https://api.ebird.org/v2/' }

sub api_key ( $self ) { $self->{api_key} }

sub _setup_ua ( $self ) {
	state $rc = require Mojo::UserAgent;
	$self->{ua} = Mojo::UserAgent->new;

	$self->{ua}->on(
		start => sub ($ua, $tx) {
        	$tx->req->headers->header( "X-eBirdApiToken", $self->api_key );
        	}
		);
	}

sub ua  ( $self ) { $_[0]->{ua} }

sub get ( $self, %args ) {
	state $base = do {
		my $base = $self->api_base_url;
		$base .= '/' unless $base =~ m|/\z|;
		Mojo::URL->new( $base );
		};

	my $path_segment = $self->expand_path_template( @args{qw(path_template args)} );
	my $url = $base->clone->path($path_segment);
	$url->query($args{query}) if defined $args{query};
	$self->ua->get( $url );
	}

sub expand_path_template( $self, $path_template, $args = {} ) {
	$path_template =~ s/\{\{ \s* (\S+) \s* \}\}/$args->{$1}/xgr;
	}

sub parse_csv ( $self, $data, $headers, $bless_into ) {
	state $rc = require Text::CSV_XS;

	my $csv = Text::CSV_XS->new;
	open my $fh, '<', \$data;

	my @rows;
	while( my $row = $csv->getline($fh) ) {
		my $object = { map { $headers->[$_] => $row->[$_] } 0 .. $#$headers };
		$object = $bless_into->new( $object ) if defined $bless_into;
		push @rows, $object;
		}
	close $fh;

	return \@rows;
	}

sub parse_location_csv ( $self, $csv_data ) {
	state $headers = [
		qw(
			locId country subnational1 subnational2 latitude longitude
			location_name last_observation all_time_species
		)
		];

	$self->parse_csv( $csv_data, $headers, 'eBird::Hotspot' );
	}

sub parse_taxonomy_csv ( $self, $csv_data ) {
	state $headers = [
		qw(
			scientific_name common_name species_code category taxon_order
			com_name_codes sci_name_codes banding_codes order family_com_name
			family_sci_name report_as extinct extinct_year
		)
		];

	$self->parse_csv( $csv_data, $headers, 'eBird::Taxonomy' );
	}

=head1 The API

=head2 Observations

=over 4


=back

=head2 Product

=over 4

=item * top_100_contributors( YYYYMMDD, $country, $subnational1 = undef, $subnational2 = undef )

=cut

package eBird::Contributor::Stat { use parent qw(Hash::AsObject) }

sub top_100_contributors ( $self, $date, $country, $subnational1 = undef, $subnational2 = undef ) {
	state $path_template = 'product/top100/{{ region_code }}/{{ year }}/{{ month }}/{{ day }}';
	state $cache;

	my( $year, $month, $day ) = $date =~ m/\A(\d{4})(\d{2})(\d{2})\z/a;

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	return $cache->{$region}{$date} if defined $cache->{$region}{$date};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			region_code => $region,
			year  => $year,
			month => $month,
			day   => $day,
			},
		);

	$cache->{$region}{$date} = [ map {
		bless $_, 'eBird::Contributor::Stat';
		}
		$tx->res->json->@* ];
	}

=item * checklist_feed_on_date( )

=cut

sub checklist_feed_on_date ( $self, ) {
	}

=item * regional_stats_in_date ( $self, $date )

=cut

sub regional_stats_in_date ( $self, ) {

	}

=item * species_list_for_a_region()

=cut

sub species_list_for_a_region ( $self, ) {

	}

=item *

=cut

sub recent_checklists ( $self, $country, $subnational1 = undef, $subnational2 = undef) {
	state $path_template = 'product/lists/{{ region }}';

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			region => $region,
			},
		);

	$tx->res->json;
	}

=item * view_checklist( CHECKLIST_ID )

=cut

sub view_checklist ( $self, $checklist_id ) {
	state $path_template = 'product/checklist/view/{{ checklist_id }}';
	state $cache;

	return $cache->{$checklist_id} if defined $cache->{$checklist_id};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			checklist_id => $checklist_id,
			},
		);

	say $tx->res->to_string;

	$cache->{$checklist_id} = $tx->res->json;
	}

=back

=head2 Geography

=over 4

=item * adjacent_regions

=cut

sub adjacent_regions ( $self, $country, $subnational1 = undef, $subnational2 = undef ) {
	state $path_template = 'ref/adjacent/{{ region_code }}';
	state %supports_subnational2 = map { $_, 1 } qw(US MX NZ);
	state $cache;

	if( defined $subnational2 ) {
		Carp::carp "Although the eBird API says that some countries support subnational2 , that is not true. Ignoring <$subnational2>.";
		$subnational2 = undef;
		}

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	return $cache->{$region} if defined $cache->{$region};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			region_code => $region,
			},
		);

	return $cache->{$country}{$subnational1} = {
		map { $_->{code} => $_->{name} } $tx->res->json->@*
		}
	}

=back

=head2  Hot Spot

=over 4

=item hotspot_in_region( COUNTRY, [, SUBNATIONAL1], [, SUBNATIONAL2] )

=cut

package eBird::Hotspot {
	use parent qw(Hash::AsObject);

	sub new( $class, $hash ) {
		delete $hash->@{qw(countryName subnational1Name subnational2Name isHotspot)};

		$hash->{country}       = delete $hash->{countryCode};
		$hash->{id}            = delete $hash->{locId};
		$hash->{name}          = delete $hash->{location_name};
		$hash->{subnational1}  = delete $hash->{subnational1Code};
		$hash->{subnational2}  = delete $hash->{subnational2Code};

		bless $hash, $class;
		}
	}

package eBird::Taxonomy {
	use parent qw(Hash::AsObject);
	use experimental qw(builtin);
	use builtin qw(true false);

	sub new( $class, $hash ) {
		foreach my $key ( qw(banding_codes com_name_codes sci_name_codes) ) {
			$hash->{$key} = { map { $_, 1 } split /\s+/, $hash->{$key} }
			}

		bless $hash, $class;
		}

	sub _code_matches ( $self, $type, $substring ) {
		foreach my $key ( keys $self->{$type}->%* ) {
			return true if $key =~ /$substring/i;
			}
		return false;
		}

	sub banding_code_matches ( $self, $substring ) {
		$self->_code_matches( 'banding_codes', $substring );
		}

	sub common_name_code_matches ( $self, $substring ) {
		$self->_code_matches( 'com_name_codes', $substring );
		}

	sub scientific_name_code_matches ( $self, $substring ) {
		$self->_code_matches( 'sci_name_codes', $substring );
		}
	}

sub hotspots_in_region ( $self, $country, $subnational1 = undef, $subnational2 = undef ) {
	state $path_template = 'ref/hotspot/{{ region_code }}';

	state $cache;

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	return $cache->{$region} if defined $cache->{$region};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			region_code => $region,
			},
		);

	my $objects = $self->parse_location_csv( $tx->res->body );

	return $cache->{$region} = $objects;
	}

=item hotspot_info( LOC_ID )

=cut

# {
#   "locId": "L99381",
#   "name": "Stewart Park",
#   "latitude": 42.4613413,
#   "longitude": -76.5054578,
#   "countryCode": "US",
#   "countryName": "United States",
#   "subnational1Name": "New York",
#   "subnational1Code": "US-NY",
#   "subnational2Code": "US-NY-109",
#   "subnational2Name": "Tompkins",
#   "isHotspot": true,
#   "hierarchicalName": "Stewart Park, Tompkins, New York, US",
#   "locID": "L99381"
# }

sub hotspot_info ( $self, $location_id ) {
	state $path_template = 'ref/hotspot/info/{{ locid }}';

	state $cache;

	return $cache->{$location_id} if defined $cache->{$location_id};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			locid => $location_id,
			},
		);

	my $hash = $tx->res->json;
	unless( keys $hash->%* ) {
		$self->cli->logger->warn( "There is no information for hotspot <$location_id>" );
		return {};
		}

	return $cache->{$location_id} = eBird::Hotspot->new( $hash );
	}

=item * nearby_hotspots( LATITUDE, LONGITUDE, DISTANCE )

=cut

sub nearby_hotspots ($self, $latitude, $longitude, $distance = 25) {
	state $path_template = 'ref/hotspot/geo';
	state $cache;

	$latitude  = sprintf '%.2f', $latitude;
	$longitude = sprintf '%.2f', $longitude;

	return $cache->{$latitude}{$longitude}{$distance}
		if defined $cache->{$latitude}{$longitude}{$distance};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			},
		query => {
			lat  => $latitude,
			lng  => $longitude,
			dist => $distance,
			},
		);

	my $objects = $self->parse_location_csv( $tx->res->body );

	return $cache->{$latitude}{$longitude}{$distance} = $objects;
	}

=back

=head2 Taxonomy

=over 4

=item * taxonomy

=cut

sub taxonomy ( $self, %query ) {
	state $path_template = 'ref/taxonomy/ebird';
	state $format = 'csv';
	state $cache;
	return Storable::dclone($cache) if defined $cache;

	$query{locale}  //= 'en';

	my $tx = $self->get(
		path_template => $path_template,
		query         => \%query,
		);

	my $objects = $self->parse_taxonomy_csv( $tx->res->body );
	return $cache = $objects;
	}

=item * taxonomy_by_band( BAND_SUBSTRING )

=cut

sub _taxonomy_by ( $self, $method, $substring ) {
	my $taxonomy = $self->taxonomy;

	my @results;
	foreach my $item ( $taxonomy->@* ) {
		next unless $item->$method( $substring );
		push @results, $item;
		}

	return \@results;
	}

sub taxonomy_by_band ( $self, $band_substring ) {
	my $results = $self->_taxonomy_by( 'banding_code_matches', $band_substring );
	}

=item * forms

=cut

sub forms ( $self, $species_code ) {
	state $path_template = 'ref/taxon/forms/{{species_code}}';
	state $cache;

	return $cache->{'species_code'} //= $self->get(
		path_template => $path_template,
		args => {
			species_code => $species_code,
			},
		);
	}

=item * locales

=cut

sub taxa_locales ( $self, ) {
	state $path_template = 'ref/taxa-locales/ebird';
	state $cache;

	my $tx = $self->get(
		path_template => $path_template,
		args => {},
		);

	my $array = $tx->res->json;
	unless( @$array ) {
		return [];
		}

	my %hash;
	foreach my $locale ( $array->@* ) {
		$hash{ $locale->{code} } = $locale;
		}

	return Storable::dclone($cache = \%hash);
	}

=item * versions

=cut

sub taxa_versions ( $self ) {
	state $path_template = 'ref/taxonomy/versions';
	state $cache;

	$cache //= $self->get(
		path_template => $path_template,
		)->res->json;

	Storable::dclone($cache);
	}

=item * groups

=cut

sub taxa_groups ( $self, %raw_args ) {
	state $path_template = 'ref/sppgroup/{{grouping}}';
	state @locales = qw(
		bg cs da de en es es_AR es_CL es_CU es_ES es_MX es_PA fr he
		is nl no pt_BR pt_PT ru sr th tr zh
		);
	state @groupings = qw(merlin ebird);
	state $cache;

	my %defaults = qw( grouping ebird );

	my %args = ( qw(grouping ebird), %raw_args{qw(grouping)} );
	my %query;
	$query{'groupNameLocale'} = $raw_args{'locale'} // 'en';

	$cache //= $self->get(
		path_template => $path_template,
		args  => \%args,
		query => \%query,
		)->res->json;

	Storable::dclone($cache);
	}

=back

=head2 Region

=over 4

=item * is_valid_parent_region_type

=cut

sub is_valid_parent_region_type ( $self, $type ) {
	state %valids = map { $_, 1 } $self->parent_region_types;
	exists $valids{$type};
	}

=item * is_valid_region

=cut

sub is_valid_region_type ( $self, $type ) {
	state %valids = map { $_, 1 } $self->region_types;
	exists $valids{$type};
	}

=item * is_valid_region_type

=cut

sub is_valid_region_type ( $self, $type ) {
	state %valids = map { $_, 1 } $self->region_types;
	exists $valids{$type};
	}

=item * region_info_for( REGION )

The major region, country, subnational1 or subnational2 code, or locId

=cut

sub region_info_for ( $self, $region ) {
	my $path_template = 'ref/region/info/{{region}}';

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			region => $region,
			},
		);

	$tx->res->json;
	}

=item * sub_region_list_for( TYPE, PARENT_REGION )

=cut

sub sub_region_list_for ( $self, $region_type, $parent_region ) {
#	return $self->invalid_region_result( $region );
	}

=item * parent_region_types

=cut

sub parent_region_types ( $self ) {
	qw(world country subnational1);
	}

=item * region_types

=cut

sub region_types ( $self ) {
	qw(country subnational1 subnational2);
	}


sub subnationals2_for_country_subnational ( $self, $country, $subnational ) {
	state $path_template = 'ref/region/list/subnational2/{{ country }}-{{ subnational }}';
	state $cache;

	return $cache->{$country}{$subnational} if defined $cache->{$country}{$subnational};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			country => $country,
			subnational => $subnational,
			},
		);

	return $cache->{$country}{$subnational} = {
		map { ( $_->{code} => $_->{name} ) } $tx->res->json->@*
		}
	}

sub subnationals_for_country ( $self, $country ) {
	state $path_template = 'ref/region/list/subnational1/{{ country }}';
	state $cache;

	return $cache->{$country} if defined $cache->{$country};

	my $tx = $self->get(
		path_template => $path_template,
		args => {
			country => $country,
			},
		);

	return $cache->{$country} = {
		map { ( $_->{code} => $_->{name} ) } $tx->res->json->@*
		}
	}

sub countries ( $self ) {
	state $path_template = 'ref/region/list/country/world';
	state $cache;
	return $cache if defined $cache;

	my $tx = $self->get(
		path_template => $path_template,
		);

	return $cache = {
		map { ( $_->{code} => $_->{name} ) } $tx->res->json->@*
		}
	}

sub country_name_with_code ( $self, $code ) {
	$self->countries->{$code};
	}

sub subregion_data ( $self, $region = undef ) {
	my @parts = split /-/, $region;

	my $hash = do {
		   if( 0 == @parts ) { $self->countries }
		elsif( 1 == @parts ) { $self->subnationals_for_country(@parts) }
		elsif( 2 == @parts ) { $self->subnationals2_for_country_subnational(@parts) }
		elsif( 3 == @parts ) {
			my %hash = map { $_->locId, $_->location_name } $self->hotspots_in_region( @parts )->@*;
			\%hash;
			}
		};

	}
=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
