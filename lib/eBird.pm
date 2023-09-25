use v5.36;
use experimental qw(signatures);

package eBird;
use strict;

use warnings;
no warnings;

our $VERSION = '0.001_01';

use experimental qw(builtin);
use builtin qw(true false weaken);

use Carp;
use Mojo::JSON qw(decode_json);
use Mojo::Util qw(dumper);

use eBird::Checklist;

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
		logger
		);

	$args{api_key} //= $ENV{EBIRD_API_KEY};

	if( defined $args{logger} ) {
		weaken($args{logger});
		}
	else {
		$args{logger} = Mojo::Log->new;
		}

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

=item * api_base_url

=cut

sub api_base_url ( $self ) { $self->{api_base_url} // 'https://api.ebird.org/v2/' }

=item * api_key

=cut

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

=item * ua

=cut

sub ua  ( $self ) { $_[0]->{ua} }

=item * get

=cut

sub get ( $self, %args ) {
	state $base = do {
		my $base = $self->api_base_url;
		$base .= '/' unless $base =~ m|/\z|;
		Mojo::URL->new( $base );
		};

	$args{json} = true unless defined $args{json};

	my $data;
	if( defined $args{cache_key} ) {
		$data = $self->load_from_cache( $args{cache_key} );
		$data = decode_json($data) if( defined $data and $args{json} );
		$self->remove_cache_items( $args{cache_key} ) unless defined $data;
		}

	return $data if defined $data;

	my $path_segment = $self->expand_path_template( @args{qw(path_template args)} );
	my $url = $base->clone->path($path_segment);
	$url->query($args{query}) if defined $args{query};
	my $tx = $self->ua->get( $url );
#	say "----\n", $tx->res->to_string, "-----\n";
	$data = $tx->res->body;

	$self->save_to_cache( $args{cache_key}, $data ) if defined $args{cache_key};

	if( $tx->res->headers->content_type =~ /json/ ) {
		$data = decode_json($data) if $args{json};
		}

	return $data;
	}

=item * expand_path_template

=cut

sub expand_path_template ( $self, $path_template, $args = {} ) {
	$path_template =~ s/\{\{ \s* (\S+) \s* \}\}/$args->{$1}/xgr;
	}

=item * logger

=cut

sub logger ( $self ) { $self->{logger} }

=item * parse_csv

=cut

sub parse_csv ( $self, $data, $headers, $bless_into ) {
	state $rc = require Text::CSV_XS;

	my $csv = Text::CSV_XS->new;
	open my $fh, '<:encoding(UTF-8)', \$data;

	my @rows;
	$csv->getline($fh); # ignore headers
	while( my $row = $csv->getline($fh) ) {
		my $object = { map { $headers->[$_] => $row->[$_] } 0 .. $#$headers };
		$object = $bless_into->new( $object ) if defined $bless_into;
		push @rows, $object;
		}
	close $fh;

	return \@rows;
	}

=item * parse_location_csv

=cut

sub parse_location_csv ( $self, $csv_data ) {
	state $headers = [
		qw(
			locId country subnational1 subnational2 latitude longitude
			location_name last_observation all_time_species
		)
		];

	$self->parse_csv( $csv_data, $headers, 'eBird::Hotspot' );
	}

=item * parse_taxonomy_csv

=cut

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

=item * cache_dir

=cut

sub cache_dir ( $self ) {
	state $default = Mojo::File->new( $ENV{HOME} )->child('.ebird-perl' )->make_path;
	state $cache_dir;
	return $cache_dir if( defined $cache_dir && -d $cache_dir );

	my $env_dir = $ENV{EBIRD_CACHE_DIR};
	if( defined $env_dir and ! -d $env_dir ) {
		$env_dir = Mojo::File->new($env_dir);
		$env_dir->make_path;
		}
	$env_dir // $default
	}

=item * list_cache

=cut

sub list_cache ( $self ) {
	$self->cache_dir->list
		->map( sub { [ $_->basename, $_->stat->ctime ] } )
		->to_array
	}

=item * load_from_cache

=cut

sub load_from_cache ( $self, $key ) {
	$self->logger->debug( "Looking for $key in cache" );
	my $file = $self->cache_dir->child($key);
	return unless -e $file;

	$self->logger->debug( "Found $key in cache" );

	Mojo::File->new($file)->slurp;
	}

=item * remove_cache_items

=cut

sub remove_cache_items ( $self, @items ) {
	foreach my $item ( @items ) {
		Mojo::File->new( $self->cache_dir )->child( $item )->remove;
		}
	}

=item * save_to_cache

=cut

sub save_to_cache ( $self, $key, $data ) {
	$self->logger->debug( "Saving data to $key. Bytes " . length $data );
	my $file = $self->cache_dir->child($key);
	$file->spurt($data);
	}

=back

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

	my( $year, $month, $day ) = $date =~ m/\A(\d{4})(\d{2})(\d{2})\z/a;

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "top100-$region-$date",
		args => {
			region_code => $region,
			year  => $year,
			month => $month,
			day   => $day,
			},
		);

	[ map { bless $_, 'eBird::Contributor::Stat'; } $data->@* ];
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

=item * recent_checklists

=cut

sub recent_checklists ( $self, $country, $subnational1 = undef, $subnational2 = undef) {
	state $path_template = 'product/lists/{{ region }}';

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "recent_checklists-$region",
		args => {
			region => $region,
			},
		);
	}

=item * view_checklist( CHECKLIST_ID )

=cut

sub view_checklist ( $self, $checklist_id ) {
	state $path_template = 'product/checklist/view/{{ checklist_id }}';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "checklist-$checklist_id",
		args => {
			checklist_id => $checklist_id,
			},
		);

	my $object = eBird::Checklist->new( $data );
	}

=back

=head2 Geography

=over 4

=item * adjacent_regions

=cut

sub adjacent_regions ( $self, $country, $subnational1 = undef, $subnational2 = undef ) {
	state $path_template = 'ref/adjacent/{{ region_code }}';
	state %supports_subnational2 = map { $_, 1 } qw(US MX NZ);

	if( defined $subnational2 ) {
		Carp::carp "Although the eBird API says that some countries support subnational2 , that is not true. Ignoring <$subnational2>.";
		$subnational2 = undef;
		}

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "adjacent_regions-$region",
		args => {
			region_code => $region,
			},
		);

	$data = { map { $_->{code} => $_->{name} } $data->@* };
	}

=back

=head2  Hot Spot

=over 4

=item * hotspots_in_region( COUNTRY, [, SUBNATIONAL1], [, SUBNATIONAL2] )

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

		$hash->{scientific_name} =~ s/\s*\[.*?\]\s*//;
		$hash->{scientific_name} =~ s/\s*\(.*?\)\s*//;
		bless $hash, $class;
		}

	sub _code_matches ( $self, $type, $pattern ) {
		foreach my $key ( keys $self->{$type}->%* ) {
			return true if $key =~ /$pattern/i;
			}
		return false;
		}

	sub banding_code_matches ( $self, $pattern ) {
		$self->_code_matches( 'banding_codes', $pattern );
		}

	sub common_name_matches ( $self, $pattern ) {
		$self->common_name =~ m/$pattern/;
		}

	sub common_name_code_matches ( $self, $pattern ) {
		$self->_code_matches( 'com_name_codes', $pattern );
		}

	sub genus ( $self ) {
		$self->{genus} //= ( split /\s+/, $self->scientific_name )[0];
		}

	sub genus_matches ( $self, $pattern ) {
		$self->genus =~ m/$pattern/;
		}

	sub family ( $self ) {
		$self->family_sci_name;
		}

	sub family_matches ( $self, $pattern ) {
		$self->family_sci_name =~ m/$pattern/;
		}

	sub order_matches ( $self, $pattern ) {
		$self->order =~ m/$pattern/;
		}

	sub species ( $self ) {
		$self->{species} //= ( split /\s+/, $self->scientific_name )[1];
		}

	sub species_matches ( $self, $pattern ) {
		$self->species =~ m/$pattern/;
		}

	sub subspecies ( $self ) {
		$self->{subspecies} //= ( split /\s+/, $self->scientific_name )[2];
		return defined $self->{subspecies} ? $self->{subspecies} : ();
		}
	}

sub hotspots_in_region ( $self, $country, $subnational1 = undef, $subnational2 = undef ) {
	state $path_template = 'ref/hotspot/{{ region_code }}';

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);
	my $cache_key = "hotspots-$region";

	my $data = $self->get(
		path_template => $path_template,
		cache_key     => $cache_key,
		args => {
			region_code => $region,
			},
		json => false,
		);

	$self->parse_location_csv( $data );
	}

=item * hotspot_info( LOC_ID )

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

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "hotspot-$location_id",
		args => {
			locid => $location_id,
			},
		);

	unless( keys $data->%* ) {
		$self->logger->warn( "There is no information for hotspot <$location_id>" );
		}

	$data
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
		cache_key => "nearby-$latitude^$longitude-$distance",
		args => {},
		query => {
			lat  => $latitude,
			lng  => $longitude,
			dist => $distance,
			},
		);

	$self->parse_location_csv( $tx->res->body );
	}

=back

=head2 Taxonomy

=over 4

=item * species_code_to_common_name

=cut

sub species_code_to_common_name ( $self, $species_code ) {
	state $index = do {
		my $taxonomy = $self->taxonomy;
		my %results;
		foreach my $item ( $self->taxonomy->@* ) {
			$results{$item->species_code} = $item;
			}

		\%results;
		};

	$self->logger->debug( "species_code_to_common_name: $species_code" );

	eval { $index->{$species_code}->common_name } // $species_code;
	}


=item * taxonomy

=cut

sub taxonomy ( $self, %query ) {
	state $path_template = 'ref/taxonomy/ebird';
	state $format = 'csv';

	$query{locale}  //= 'en';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "taxonomy-$query{locale}",
		query         => \%query,
		json          => false,
		);

	$self->parse_taxonomy_csv( $data );
	}

sub _taxonomy_by ( $self, $method, $substring ) {
	my $taxonomy = $self->taxonomy;

	my @results;
	foreach my $item ( $taxonomy->@* ) {
		next unless $item->$method( $substring );
		push @results, $item;
		}

	return \@results;
	}

=item * taxonomy_by_band( BAND_SUBSTRING )

=cut

sub taxonomy_by_band ( $self, $pattern ) {
	$self->_taxonomy_by( 'banding_code_matches', $pattern );
	}

=item * taxonomy_by_common_name( BAND_SUBSTRING )

=cut

sub taxonomy_by_common_name ( $self, $pattern ) {
	$self->_taxonomy_by( 'common_name_matches', $pattern );
	}

=item * taxonomy_by_family( BAND_SUBSTRING )

=cut

sub taxonomy_by_family ( $self, $pattern ) {
	$self->_taxonomy_by( 'family_matches', $pattern );
	}

=item * taxonomy_by_genus( BAND_SUBSTRING )

=cut

sub taxonomy_by_genus ( $self, $pattern ) {
	$self->_taxonomy_by( 'genus_matches', $pattern );
	}

=item * taxonomy_by_order( BAND_SUBSTRING )

=cut

sub taxonomy_by_order ( $self, $pattern ) {
	$self->_taxonomy_by( 'order_matches', $pattern );
	}

=item * taxonomy_all_bands()

=cut

sub taxonomy_all_bands ( $self ) {
	my $taxonomy = $self->taxonomy;

	my %results;
	foreach my $item ( $taxonomy->@* ) {
		$results{$_} = $item for keys $item->{banding_codes}->%*;
		}

	return \%results;
	}

=item * forms

=cut

sub forms ( $self, $species_code ) {
	state $path_template = 'ref/taxon/forms/{{species_code}}';

	$self->get(
		path_template => $path_template,
		cache_key => "forms-$species_code",
		args => {
			species_code => $species_code,
			},
		);
	}

=item * taxa_locales

=cut

sub taxa_locales ( $self ) {
	state $path_template = 'ref/taxa-locales/ebird';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "locales",
		args => {},
		);

	my %hash;
	foreach my $locale ( $data->@* ) {
		$hash{ $locale->{code} } = $locale;
		}

	return \%hash;
	}

=item * taxa_versions

=cut

sub taxa_versions ( $self ) {
	state $path_template = 'ref/taxonomy/versions';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => 'versions',
		);
	}

=item * taxa_groups

=cut

sub taxa_groups ( $self, %raw_args ) {
	state $path_template = 'ref/sppgroup/{{grouping}}';
	state @locales = qw(
		bg cs da de en es es_AR es_CL es_CU es_ES es_MX es_PA fr he
		is nl no pt_BR pt_PT ru sr th tr zh
		);
	state @groupings = qw(merlin ebird);

	my %defaults = qw( grouping ebird );

	my %args = ( qw(grouping ebird), %raw_args{qw(grouping)} );
	my %query;
	$query{'groupNameLocale'} = $raw_args{'locale'} // 'en';

	$self->get(
		path_template => $path_template,
		cache_key => "groups-$query{'groupNameLocale'}-$args{'grouping'}",
		args  => \%args,
		query => \%query,
		);
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


=item * subnationals2_for_country_subnational

=cut

sub subnationals2_for_country_subnational ( $self, $country, $subnational ) {
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

sub subnationals_for_country ( $self, $country ) {
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

=item * countries

=cut

sub countries ( $self ) {
	state $path_template = 'ref/region/list/country/world';
	state $cache_key = 'countries';

	my $data = $self->get(
		path_template => $path_template,
		cache_key     => $cache_key,
		);

	$data = {
		map { ( $_->{code} => $_->{name} ) } decode_json($data)->@*
		};

	return $data
	}

=item * country_name_with_code

=cut

sub country_name_with_code ( $self, $code ) {
	$self->countries->{$code};
	}

=item * subregion_data

=cut

sub subregion_data ( $self, $region = undef ) {
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

Copyright © 2023, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
