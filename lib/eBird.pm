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

use namespace::autoclean;
use Carp;
use Cwd qw();
use File::Spec::Functions qw(catfile);
use Mojo::JSON qw(decode_json);
use Mojo::Log;
use Mojo::Util qw(dumper);
use Ref::Util qw(:all);
use String::Redactable qw();

use eBird::Cache;
use eBird::Config;
use eBird::IO;
use eBird::Region qw(:all);
use eBird::Util;

=encoding utf8

=head1 NAME

eBird - play with the eBird API and website

=head1 SYNOPSIS

	use eBird;

	my $ebird = eBird->new;

=head1 DESCRIPTION

The C<eBird> module coordinates the various things the rest of the system
needs.

=head2 Class methods

=over 4

=item * default_api_base

Returns the default base URL for the eBird API, I<https://api.ebird.org/v2>.

=cut

sub default_api_base ($class) { 'https://api.ebird.org/v2' }

=item * default_cache_dir

Creates the cache dir if it does not exist, and returns its path. By default,
this directory is named C<cache> under the directory from C<default_dir>.

=cut

sub default_cache_dir ($class) { $class->default_dir->child('cache')->make_path }

=item * default_config_file

Creates the config file (empty) if it does not exist, and returns its path.
By default, this is F<config.toml> under the directory from C<default_dir>.

=cut

sub default_config_file ($class) { $class->default_dir->child('config.toml')->touch }

=item * default_dir

Returns the default directory for L<eBird>, which is F<.ebird-perl> under the
home directory.

=cut

sub default_dir ($class) { Mojo::File->new( eBird::Util::home_dir() )->child('.ebird-perl')->make_path }

=item * new

=cut

sub new ($class, %args) {
	state %defaults = (
		api_base_url => 'https://api.ebird.org/v2',
		cache        => eBird::Cache->new( dir => $class->default_cache_dir  ),
		config       => eBird::Config->new( $class->default_config_file ),
		io           => eBird::IO->new,
		);
	state %allowed = map { $_, 1 } qw(
		api_base_url
		cache
		config
		io
		locale
		logger
		);

	$args{'logger'} //= do {
		my $dir = $class->default_dir;
		my $path = $dir->child('ebird.log');
		Mojo::Log->new( path => $path, level => ($ENV{'EBIRD_LOG_LEVEL'} // 'warn') );
		},

	my $self = bless {
		%defaults,
		map { $_, $args{$_} } grep { $allowed{$_} } keys %args,
		}, $class;

	$self->add_endpoints;

	$self->_setup_ua();

	return $self;
	}

=back

=head2 Instance methods

=over 4

=item * add_endpoints

Finds each C<eBird::Endpoint> modules and calls C<add_endpoint> with it.

=cut

sub add_endpoints ($self) {
	state $endpoints = [
		map { "eBird::Endpoint::$_" }
			qw(Hotspot Geo Observation Product Region Taxonomy Website)
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
	eBird::Util::load_module($namespace, $self) or return;
	my $name = lc $namespace->name;
	my $obj = $namespace->new( ebird => $self );

	{
	no strict 'refs';
	*{__PACKAGE__ . '::' . $name} = sub { $obj };
	}

	return 1;
	}

=item * api_base_url

Returns the API base URL that the object is using, or the default value.

=cut

sub api_base_url ( $self ) { $self->{'api_base_url'} // $self->default_api_base }

=item * api_key

Returns the API key object, which is a L<String::Redactable> object to protect
the sensitive value.

=cut

sub api_key ( $self ) { $self->config->api->api_key }

=item * cache

=cut

sub cache ( $self ) { $self->{'cache'} //= eBird::Cache->new( dir => $self->default_cache_dir ) }

=item * config

=cut

sub config ( $self ) { $self->{'config'} //= eBird::Config->new( $self->default_config_file ) }

=item * dir

=cut

sub dir ( $self ) { $self->{'dir'} //= $self->default_dir }

=item * expand_path_template

=cut

sub expand_path_template ( $self, $path_template, $args = {} ) {
	$path_template =~ s/\{\{ \s* (\S+?) \s* \}\}/$args->{$1}/xgr;
	}

=item * get


=cut

sub get ( $self, %args ) {
	state $base = do {
		my $base = $self->api_base_url;
		$base .= '/' unless $base =~ m|/\z|;
		Mojo::URL->new( $base );
		};

	$args{json} //= 1;

	my $data;

	# try it from the cache first
	if( defined $args{'cache_key'} and $self->cache->exists($args{'cache_key'}) ) {
		$self->logger->debug( 'get: cache hit for ' . $args{'cache_key'} );
		$data = $self->cache->load( $args{'cache_key'} );
		$self->logger->debug( 'get: cache hit for ' . $args{'cache_key'} , ' has length ' . length $data );

		$data = decode_json($data) if( defined $data and $args{'json'} );
		$self->cache->remove( $args{'cache_key'} ) unless defined $data;
		}

	# did not get it from cache, so get it live. If data is empty, it was
	# probably in the cache by mistake.
	unless( defined $data and 0 < length $data ) {
		my $path_segment = $self->expand_path_template( @args{qw(path_template args)} );
		my $url = $base->clone->path($path_segment);
		$url->query($args{'query'}) if defined $args{'query'};

		my $tx = $self->ua->get( $url );
		unless( $tx->result->is_success ) {
			$self->io->error(
				sprintf "Could not fetch URL <%s>. Code: %s Response: %s",
					$url,
					$tx->res->code,
					$tx->res->headers->to_string
				);
			return;
			}

		$data = $tx->res->body;
		$self->cache->save( $args{'cache_key'}, $data ) if defined $args{'cache_key'};

		if( $tx->res->headers->content_type =~ /json/ ) {
			$data = decode_json($data) if $args{'json'};
			}
		}

	if( $args{'callback'} ) {
		foreach my $i ( 0 .. $data->$#* ) {
			$data->[$i] = $args{'callback'}->($data->[$i]);
			}
		}

	if( $args{'bless_into'} ) {
		eBird::Util::load_module($args{'bless_into'});
		if( is_arrayref($data) and ref $data->[0] ) {
			foreach my $hash ( $data->@* ) {
				bless $hash, $args{'bless_into'};
				}
			}
		elsif( is_arrayref($data) or is_hashref($data) ) {
			bless $data, $args{'bless_into'}
			}
		}

	return $data;
	}

=item * io

Returns the C<io> object to use for all output.

=cut

sub io ($self) { $self->{'io'} }

=item * locale

Returns the locale short code. This is the locale that we'll use throughout
anything using. The default

=cut

sub locale ($self) { $self->config->general->locale };

=item * logger

=cut

sub logger ( $self ) { $self->{logger} //= Mojo::Log->new }


=item * ua

Returns the web user-agent.

=cut

sub ua ($self) { $self->{'ua'} }

=item * ua_cookies_file

The file in which to store the Mojo cookies.

=cut

sub ua_cookies_file ( $self ) {
	$self->default_dir->child('cookies.txt');
	}

sub _setup_ua ( $self ) {
	state $rc = require Mojo::UserAgent;
	state $cookie_jar = do {
		#$self->logger->debug("Cookies file is " . $self->ua_cookies_file );
		# Mojo::UserAgent::CookieJar->new( file => $self->ua_cookies_file );
		Mojo::UserAgent::CookieJar->new;
		};
	$self->{'ua'} = Mojo::UserAgent->new;
	$self->{'ua'}->cookie_jar($cookie_jar);

	$self->{'ua'} = $self->{'ua'}->max_redirects(5);

	$self->{'ua'}->on(
		start => sub ($ua, $tx) {
			$self->logger->debug( "Mojo start: " . $tx->req->url );
			if( $tx->req->url->host eq 'api.ebird.org' ) {
        		$tx->req->headers->header( "X-eBirdApiToken", $self->config->api->api_key->to_str_unsafe );
        		}
			$tx->on(
				finish => sub ($tx) {
					$self->logger->debug( "finish: " . sprintf "Mojo finish (%s) %s", $tx->res->code, $tx->req->url );
					$self->logger->debug( "---- finish: request was --------\n" . $tx->req->to_string =~ s/\R\R+.*//sr . "\n-----------\n");
					$self->logger->debug( "---- finish: response was --------\n" . $tx->res->to_string =~ s/\R\R+.*//sr . "\n-----------\n");
					}
				) if 0;
			}
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
