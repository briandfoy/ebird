use v5.38;
use utf8;
no feature qw(module_true);

use experimental qw(signatures);

package eBird;
use strict;

use warnings;
no warnings;

our $VERSION = '0.001_01';

use experimental qw(builtin);
use builtin qw(true false weaken);

use Carp;
use File::Spec::Functions qw(catfile);
use Mojo::JSON qw(decode_json);
use Mojo::Log;
use Mojo::Util qw(dumper);
use Ref::Util qw(:all);
use String::Redactable qw();

use eBird::Cache;
use eBird::Checklist;

use eBird::Region qw(:all);

=encoding utf8

=head1 NAME

eBird - Access to the eBird API

=head1 SYNOPSIS

	use eBird;

=head1 DESCRIPTION

=over 4

=item * new

=cut

sub new ( $class, %args ) {
	state %defaults = (
		api_base_url => 'https://api.ebird.org/v2',
		);
	state %allowed = map { $_, 1 } qw(
		api_key
		cache
		logger
		);

	$args{'api_key'} //= $ENV{'EBIRD_API_KEY'};
	$ENV{'EBIRD_API_KEY'} = $args{'api_key'};
	$args{'api_key'} = String::Redactable->new($args{'api_key'});

	if( defined $args{'logger'} ) {
		weaken($args{'logger'});
		}
	else {
		$args{'logger'} = Mojo::Log->new;
		}

	if( defined $args{'cache'} ) {
		weaken($args{'cache'});
		}
	else {
		$args{'cache'} = eBird::Cache->new;
		}

	my $self = bless {
		%defaults,
		map { $_, $args{$_} } grep { $allowed{$_} } keys %args,
		}, $class;

	$self->add_endpoints;

	$self->_setup_ua();

	return $self;
	}

=item * add_endpoints

Finds each C<eBird::Endpoint> modules and calls C<add_endpoint> with it.

=cut

sub add_endpoints ($self) {
	state $endpoints = [
		map { "eBird::Endpoint::$_" } qw(Geo Region)
		];

	$self->add_endpoint($_) for $endpoints->@*;
	}

=item * add_endpoint( NAMESPACE )

This loads the namespace and creates a method based on the C<name> method
from C<NAMESPACE>.  For example, for C<eBird::Endpoint::Geo->name> returns
C<geo>, so this method creates a C<geo> method that returns the a C<eBird::Endpoint::Geo>
object:

	$eBird->geo->...

=cut

sub add_endpoint ($self, $namespace) {
	$self->load_module($namespace) or return;
	my $name = lc $namespace->name;
	my $obj = $namespace->new( ebird => $self );

	{
	no strict 'refs';
	*{__PACKAGE__ . '::' . $name} = sub { $obj };
	}

	return 1;
	}

=item * get


=cut

sub get ( $self, %args ) {
	state $base = do {
		my $base = $self->api_base_url;
		$base .= '/' unless $base =~ m|/\z|;
		Mojo::URL->new( $base );
		};

	$args{json} //= true;

	my $data;

	$self->logger->debug( "get: cache key is $args{cache_key}" );
	$self->logger->debug( "get: args => " . dumper(\%args) );

	my $data;
	if( defined $args{cache_key} ) {
		$data = $self->cache->load( $args{cache_key} );

		$data = decode_json($data) if( defined $data and $args{json} );
		# $self->logger->debug( "get: data is -----\n" . dumper($data) . "\n-------\n" );
		$self->cache->remove( $args{cache_key} ) unless defined $data;
		}

	unless( defined $data ) {
		my $path_segment = $self->expand_path_template( @args{qw(path_template args)} );
		my $url = $base->clone->path($path_segment);
		$url->query($args{query}) if defined $args{query};

		my $tx = $self->ua->get( $url );
		$data = $tx->res->body;
		$self->logger->debug( $tx->req->to_string );
		$self->cache->save( $args{cache_key}, $data ) if defined $args{cache_key};

		if( $tx->res->headers->content_type =~ /json/ ) {
			$data = decode_json($data) if $args{json};
			}
		}

	if( $args{'bless_into'} ) {
		$self->load_module($args{'bless_into'});
		if( is_arrayref($data) ) {
			foreach my $hash ( $data->@* ) {
				bless $hash, $args{'bless_into'};
				}
			}
		elsif( is_hashref($data) ) {
			bless $data, $args{'bless_into'};
			}
		}

	return $data;
	}

=item * load_module

=cut

sub load_module ($self, $namespace) {
	my $file = catfile( split /::/, $namespace ) . '.pm';
	my $rc = eval { require $file };
	if( $@ ) {
		carp "Could not load <$namespace>: $@";
		return;
		}
	return $rc;
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
        	$tx->req->headers->header( "X-eBirdApiToken", $self->api_key->to_str_unsafe );
        	}
		);
	}

=item * ua

=cut

sub ua  ( $self ) { $self->{ua} }


=item * expand_path_template

=cut

sub expand_path_template ( $self, $path_template, $args = {} ) {
	$path_template =~ s/\{\{ \s* (\S+?) \s* \}\}/$args->{$1}/xgr;
	}

=item * logger

=cut

sub logger ( $self ) { $self->{logger} //= Mojo::Log->new }

=item * output

=cut

sub output ( $self ) { $self->{output} }

=item * cache

=cut

sub cache ( $self ) { $self->{cache} //= eBird::Cache->new }

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
