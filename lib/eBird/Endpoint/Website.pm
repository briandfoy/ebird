use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Website;
use parent qw(eBird::Endpoint::Base);

use experimental qw(builtin for_list);

use builtin qw(ceil);

use namespace::autoclean;
use eBird::Util qw();

use Mojo::DOM;
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Util qw(decode dumper);
use Time::Moment;

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Website - a virtual endpoint that actually looks at the website, not the API

=head1 SYNOPSIS

	use eBird;

	my $ebird = eBird->new;

	my @checklists = $ebird->website->checklists;


=head1 DESCRIPTION

This module stands to the side of the rest of the code since this interacts
with the website instead of the API since the API does not have a way to get the
list of checklists for a user.

=head2 Instance methods

=over 4


=item * checklists


=cut

sub checklists ($self) {
	my $ebird = $self->ebird;
	$ebird->io->output( 'In checklists' );

	my $checklists = $self->checklists_summary // [];

	$self->ebird->io->output( sprintf "There are %d checklists", scalar $checklists->@* );

	return;
	}


=back

=head2 GPS Track tools

=over 4

=item * create_gpx

=cut

sub create_gpx ($self, $hash) {
	return;
	$self->logger->debug( "create_gpx: starting" );
	$self->logger->debug( "create_gpx: hash: " . dumper($hash) );

	my $start_tm = Time::Moment->new(
		$hash->%{qw(year month day hour minute)},
		offset => $hash->{'timezonedb'}{'gmtOffset'} / 3600,
		);

	my $interval = eval { $hash->{'seconds'} / $hash->{'track'}->@* };
	my $offset = 0;

	my $track_segment = Mojo::DOM->new_tag('trkseg');

	foreach my $point ( $hash->{track}->@* ) {
		my $this_tm = $start_tm->plus_seconds( $interval + $offset++ );

		# 2023-08-05T09:43:29-04:00
		my $time = Mojo::DOM->new_tag('time')->at('time')->content(
			$start_tm->plus_seconds( $interval + $offset++ )->strftime( '%Y-%m-%dT%H:%M:%S%:z' )
			);

		my $track_point = Mojo::DOM->new_tag('trkpt');

		$track_point->at('trkpt')
			->attr( 'lat' => $point->[0] )
			->attr( 'lon' => $point->[1] )
			->content( $time );
			;

		$track_segment->at('trkseg')->append_content( $track_point );
		}

	my $track = Mojo::DOM->new_tag('trk');
	$track->at('trk')->append_content( Mojo::DOM->new_tag('name') );
	$track->at('trk')->append_content( Mojo::DOM->new_tag('desc') );
	$track->at('trk')->append_content( $track_segment );

	my $gpx = Mojo::DOM->new_tag('gpx');
	$gpx->at('gpx')
		->attr( 'version' => '1.1' )
		->attr( 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance' )
		->attr( 'xmlns' => 'http://www.topografix.com/GPX/1/1' )
		->attr( 'xsi:schemaLocation' => 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd' )
		->attr( 'creator' => 'ebird-perl' )
		->append_content( $track )
		->to_string;

	$gpx =~ s/<(name|desc|trkseg)/\n  $&/gn;
	$gpx =~ s/<trkpt/\n    $&/gn;
	$gpx =~ s|</trkpt>|    $&|gn;
	$gpx =~ s|<time>|\n      $&|gn;
	$gpx =~ s|</time>|$&\n|gn;

	return $gpx;
	}

=item * get_timezone_info

=cut

sub get_timezone_info ( $self, $latitude, $longitude, $epoch = time() ) {
	$self->logger->debug( "get_timezone_info: starting" );

	my $cache_key = sprintf 'timezone-^%.2f^%.2f-%d', $latitude, $longitude, $epoch;

	my $data = $self->cache->load( $cache_key );
	return decode_json($data) if $data;

	$data = geo_to_timezone( $latitude, $longitude, $epoch );

	$self->cache->save( $cache_key, encode_json($data) );

	return $data;
	}

=item * get_track

=cut

sub get_track ( $self, $checklist ) {
	$self->logger->debug( "get_track: starting" );
	my $html = $self->get_checklist_html( $checklist );
	unless( defined $html ) {
		$self->logger->debug( "get_track: did not receive any html" );
		return
		}

	my $hash = $self->extract_checklist_details( $html );
	# $self->logger->debug( "get_track: starting" . dumper($hash) );

	$self->logger->debug( "track: " . substr( $hash->{'track_string'}, 0, 50) . "..." );
	# $self->logger->debug( "get_track: starting" . dumper($hash) );
	my $gpx = $self->create_gpx($hash);

	$gpx;
	}

=item * get_checklist_html

=cut

sub get_checklist_html ( $self, $checklist ) {
	my $cache_key = "website-checklist-$checklist";
	$self->logger->debug( "get_track: get_checklist_html" );

	my $data = $self->cache->load( $cache_key );
	return $data if $data;

	$self->logger->debug( "get_checklist_html: did not find HTML in cache, so fetching checklist $checklist" );

	unless( $self->login_to_ebird() ) {
		$self->logger->debug( "get_checklist_html: could not log into eBird" );
		return
		}

	my $checklist_url = sprintf 'https://ebird.org/checklist/%s', $checklist;
	my $checklist_tx = $self->ua->get( $checklist_url );
	my $html = $checklist_tx->res->body;

	$self->cache->save( $cache_key, $html );

	return $html;
	}

=item * extract_checklist_details

=cut

sub extract_checklist_details ( $self, $html ) {
	my $dom = Mojo::DOM->new($html);

	my %hash;

	my $primary_details = $dom->at( 'h2#primary-details' );
	$hash{'datetime'} = $primary_details->at( 'div time[datetime]' )->attr( 'datetime' );
	$self->logger->debug( "datetime is $hash{datetime}" );

	@hash{qw(year month day hour minute)} =
		$hash{'datetime'} =~ /(\d\d\d\d)-(\d\d?)-(\d\d?)T(\d\d):(\d\d)/;

	$hash{'epoch'} = Time::Moment->new( %hash{qw(year month day hour minute)} )->epoch;

	my $other_details = $dom->at( 'section[aria-labelledBy="other-details-effort"]' );
	$hash{'protocol'} = $other_details->at( 'div[title^="Protocol:"] span.Heading-main' )->text;
	$self->logger->debug( "protocol is $hash{protocol}" );

	$hash{'region'} = $dom->at( 'a[href^=/region/]' )->attr( 'href' );

	my @details = qw(observers duration distance);
	foreach my $detail ( @details ) {
		my $title = ucfirst( lc $detail );
		$self->logger->debug( "detail is $detail, title is $title" );
		$hash{$detail} = $other_details->at( qq(span[title^="$title:"] span:last-of-type) )->text;
		$self->logger->debug( "$detail is $hash{$detail}" );
		}

	$self->logger->debug( "duration is $hash{duration}" );
	if( $hash{'duration'} =~ m/
		(?:(?<hours>\d+) \x20 hr,\x20)?
		(?:(?<minutes>\d+) \x20 min)
		/x ) {
		@hash{qw(hours minutes)} = @+{qw(hours minutes)};
		$hash{'seconds'} = ( $hash{'hours'}  // 0 ) * 60 * 60 + $hash{'minutes'} * 60;
		};

	$hash{'track_string'} = eval {$dom->at( 'div#tracks-map-mini div div.Track' )
		->attr( 'data-maptrack-data' ) };
	# track is long,lat ... but most things want lat,long
	if( length $hash{'track_string'} ) {
		foreach my( $long, $lat ) ( split /\s*,\s*/, $hash{'track_string'} ) {
			push $hash{'track'}->@*, [ $lat, $long ];
			}
		$hash{'timezonedb'} = $self->get_timezone_info( $hash{'track'}->[0]->@*, $hash{'epoch'} );
		$self->logger->debug( 'extract_checklist_details: geo: ' . dumper($hash{'timezomedb'}) );
		}

	\%hash;
	}

sub _extract_item_details ( $li ) { # This is not a methond
	state $rc = require Time::Moment;
	state %months =
		map { state $n = 1; $_, $n++ }
		qw(January February March April May June July August September October November December);

	my $sequence = $li->at( 'div.ResultsStats-index span' )->text =~ s/\D//gr;

	my $checklist = $li->at( 'div.ResultsStats-title h3 a' )->attr( 'href' ) =~ s|.*/||r;
	my $title = $li->at( 'div.ResultsStats-title h3 a' )->attr( 'title' );

	my $hide = $li->at( 'div.ResultsStats-details div.u-hideForMedium div.GridFlex' );

	my $location = $hide->at( 'div.ResultsStats-details-location' )->text;
	my( $subnational2, $subnational1, $region ) = $hide->find( 'div.Breadcrumbs ul li' )
		->map( sub { $_->text } )
		->to_array
		->@*
		;

	my $date = $title =~ m/
		-
		\s+
		(?<day_name>\S+?)
		, \s+
		(?<month>\S+)
		\s+
		(?<date>\d+)
		, \s+
		(?<year>\d+)
		(
			\s+
			(?<hour>\d+) : (?<minute>\d+)
			\s+
			(?<meridian>[AP]M)
		)?
		/ax;

	my $hour  = do { no warnings; $+{hour} + ($+{meridian} eq 'PM' ? 12 : 0) };
	my $month = $months{$+{month}};

	my $time = do {
		if( defined $+{hour} ) {
			my $hour  = $+{hour} + (($+{meridian} eq 'PM' && $+{hour} != 12) ? 12 : 0);

			{ hour => $hour, minute => $+{minute}, second => 0, offset => '-0400' }
			}
		else { {} }
		};

	my $tm = eval { Time::Moment->new(
		year       => $+{year},
		month      => $month,
		day        => $+{date},
		$time->%*
		) };

	my $hash = {
		location     => $location,
		subnational2 => $subnational2,
		subnational1 => $subnational1,
		region       => $region,
		sequence     => $sequence,
		datetime     => $tm,
		day          => $+{day_name},
		year         => $+{year},
		month        => $month,
		date         => $+{date},
		epoch        => $tm->epoch,
		checklist    => $checklist,
		title        => $title,
		$time->%*,
		}
	}

=item * checklists_summary

If we have the checklist summary in the cache, return that immediately.

If not, fetch the checklist summary from the website.

=cut

sub checklists_summary ( $self ) {
	my $cache_key = join '-', $self->ebird->config->website->username, 'checklist-summary' ;

	my $checklist_summary;
	if( $self->ebird->cache->exists($cache_key) ) {
		$self->ebird->logger->debug("checklists_summary: cache key <$cache_key> exists");
		my $raw_data = $self->ebird->cache->load( $cache_key );
		$checklist_summary = eval { decode_json($raw_data) };
		if( defined $checklist_summary ) {
			$self->ebird->logger->debug("checklists_summary: Returning cached data for <$cache_key>");
			return $checklist_summary;
			}
		$self->ebird->logger->error("Could not load JSON for <$cache_key>: $@");
		}

	$self->ebird->logger->debug( "will try to log into eBird" );
	unless( $self->login_to_ebird ) {
		$self->ebird->logger->error( "Could not login to fetch checklists" );
		return;
		}

	# https://ebird.org/mychecklists?currentRow=1&sortBy=date&o=desc
	my $params = {
		currentRow => 1,
		sortBy     => 'date',
		o          => 'desc',
		};

	my @checklists;
	my $highest;
	my $expected_pages =   1;
	my $page           =   0;
	my $per_page       = 100;

	while( $page <= $expected_pages ) {
		$page++;

		$self->ebird->logger->debug( "checklists_summary: Fetching page <$page> of <$expected_pages>" );

		my $html = $self->fetch_list_page( $page, $per_page );
		unless( length $html ) {
			$self->ebird->logger->error( "HTML for checklist page was empty" );
			return [];
			}

		push @checklists, Mojo::DOM->new($html)->find( 'li[id^="checklist-"]' )
			->map( \&_extract_item_details )
			->to_array
			->@*;
		if( @checklists == 0 ) {
			$self->ebird->logger->error( "Could not extract any checklists from HTML" );
			return [];
			}

		$highest = $checklists[0]->{'sequence'};
		unless( $highest ) {
			$self->ebird->logger->error( "First checklist item did not have a sequence" );
			return [];
			}

		state $n = do {
			$per_page = @checklists;
			$self->ebird->logger->debug( "per page is <$per_page>" );
			$self->ebird->logger->debug( "Highest checklist is <$highest>" );
			$expected_pages = ceil( eval{ $highest / $per_page } );
			$self->ebird->logger->debug( "Expected pages is <$expected_pages>" );
			};
		}

	$self->ebird->cache->save( $cache_key, encode_json(\@checklists) );
	return \@checklists;
	}

=item * fetch_list_page

=cut

sub fetch_list_page ( $self, $page, $per_page = 100 ) {
	$self->ebird->logger->debug("fetch_list_page: page <$page> per page <$per_page>");
	my $cache_key = sprintf "%s-website-checklist-page-$page", $self->ebird->config->website->username;

	if( $self->ebird->cache->exists($cache_key) ) {
		$self->ebird->logger->debug("fetch_list_page: found in cache <$cache_key>");
		my $html = $self->ebird->cache->load_decode( $cache_key );
		$html = eval { decode( 'UTF-8', $html ) };
		return $html if defined $html;
		}

	my $params = {
		currentRow => ($per_page * ($page-1)) + 1,
		sortBy     => 'date',
		o          => 'desc',
		};

	my $checklists_tx = $self->ebird->ua->get( 'https://ebird.org/mychecklists' => form => $params );
	my $html =  $checklists_tx->res->body;
	$self->ebird->cache->save( $cache_key, $html );

	$html = eval { decode( 'UTF-8', $html ) };
	unless( defined $html ) {
		$self->ebird->logger->error("Could not decode HTML: $@");
		return;
		}
	$self->ebird->logger->debug( "fetch_list_page: found HTML with length " . length $html );


	return $html;
	}

=back

=head2 Logging In

=over 4

=item * am_logged_in

Accesses the landing page and looks at the response to guess if the user-agent
is logged in.

Even if there is a session cookie, that cookie might have expired.

=cut

sub am_logged_in ( $self ) {
	$self->ebird->logger->debug('am_logged_in: Checking if we are logged in');
	my $tx = $self->ebird->ua->get($self->landing_page);
	$self->ebird->logger->debug('am_logged_in: Response code was ' . $tx->res->code);

	my $found_current_region = $tx->res->body =~ m/Current \h+ region:/xi;
	$self->ebird->logger->debug( 'am_logged_in: ' .
		($found_current_region ?
			'Found the text "Current Region", so we are logged in'
			:
			'Did not see "Current Region", so guessing we are not logged in'
			)
		);

	return !! $found_current_region;
	}

=item * check_credentials

=cut

sub check_credentials ($self) {
	my @errors = ();
	unless( $self->ebird->config->website->username ) {
		push @errors, "No website password in the config"
		}

	unless( defined $self->ebird->config->website->password ) {
		push @errors, "No website password in the config"
		}

	foreach my $error ( @errors ) {
		$self->ebird->logger->error( "check_credentials: $error" );
		}

	return ! @errors;
	}

=item * landing_page

Returns the URL of the landing page.

=cut

sub landing_page ($self) {
	'https://ebird.org/home'
	}

=item * login_to_ebird

Go through the website login process to get the session information that we
need. If we are already logged in, this returns without doing anything.

Call this before any operation where you need to interact with the website.

=cut

sub login_to_ebird ( $self ) {
	$self->ebird->logger->debug( "login_to_ebird: starting" );
	$self->ebird->logger->debug( "login_to_ebird: username is " . $self->ebird->config->website->username );

	if( $self->am_logged_in ) {
		$self->ebird->logger->debug( "login_to_ebird: am logged in" );
		return $self->{'logged_in'} = 1;
		};
	$self->ebird->logger->debug( "login_to_ebird: not logged in--continuing" );

	# first, see if we are logged in. We might have
	unless( $self->check_credentials ) {
		$self->ebird->logger->error( "login_to_ebird: Could not get login credentials for the website. Check the config.");
		return;
		}

	my $ua = $self->ebird->ua;

	$self->ebird->logger->debug( "login_to_ebird: did not find JSESSIONID, so logging in" );

	# Start with the landing page
	LANDING_PAGE: {
		my $tx = $ua->get( $self->landing_page );

		my $location = Mojo::URL->new( $tx->req->url )->query(Mojo::Parameters->new);
		$self->ebird->logger->debug(  "Status: " . $tx->res->code );
		$self->ebird->logger->debug(  Mojo::Util::dumper( $ua->cookie_jar ) );

		if( $tx->res->code eq '302' ) {
			my $location = $tx->res->headers->location;
			$self->ebird->logger->debug( "LOCATION: $location" );
			$tx = $ua->get($location);
			}
		$self->ebird->logger->debug(  "Status: " . $tx->res->code );
		}

	LOGIN_PAGE: {
		my $tx = $ua->get( "https://secure.birds.cornell.edu/cassso/login?service=https%3A%2F%2Febird.org%2Flogin%2Fcas%3Fportal%3Debird&locale=en_US" );

		my $form;
		unless( $tx->res->is_success and $form = $tx->res->dom->at('form') ) {
			$self->ebird->logger->debug( "login_to_ebird: Could not get login page" );
			return;
			}

		unless( $form = $tx->res->dom->at('form') ) {
			$self->ebird->logger->debug( "login_to_ebird: Did not find login form" );
			return;
			}

		my $params = {
			service     => 'https://ebird.org/login/cas?portal=ebird',
			locale      => 'en_US',
			username    => $self->ebird->config->website->username,
			password    => $self->ebird->config->website->password->to_str_unsafe,
			remember_me => 'on',
			execution   => $form->at( 'input[name=execution]' )->attr( 'value' ),
			'_eventId'  => $form->at( 'input[name=_eventId]' )->attr( 'value' ),
			submit      => 'Sign in',
			};
		$self->ebird->logger->debug( "login_to_ebird: params: " . Mojo::Util::dumper($params));
		my $headers = {
			'Referer' => $self->landing_page,
			};

		my $action_url = 'https://secure.birds.cornell.edu/cassso/login';
		my $post_tx = $ua->post( $action_url => $headers => form => $params );
		$self->ebird->logger->debug( "login_to_ebird: response code " . $tx->res->code );
		$self->ebird->logger->debug( "login_to_ebird: response was " . $tx->res->to_string =~ s/\R\R+.*//sr );

		unless( $post_tx->res->is_success ) {
			$self->{'logged_in'} = 0;
			$self->ebird->logger->error( "login_to_ebird: Post failed:\n" . $post_tx->req->to_string . "\n\n" . $post_tx->res->to_string );
			return;
			}
		}

	unless( $self->am_logged_in ) {
		$self->ebird->logger->debug( "login_to_ebird: not logged in after trying" );
		return $self->{'logged_in'} = 0;
		};

	$self->ebird->logger->debug( "login_to_ebird: Login succeeded" );

	$ua->cookie_jar->save;

	$self->{'logged_in'} = 1;
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

__END__
[2023-09-27 18:21:51.62414] [18095] [debug] login_to_bird: after login cookies are bless( {
  "file" => "cookies.txt",
  "jar" => {
    "ebird.org" => [
      bless( {
        "domain" => "ebird.org",
        "host_only" => 1,
        "httponly" => 1,
        "name" => "EBIRD_SESSIONID",
        "path" => "/",
        "secure" => 1,
        "value" => "9D59B446EF1178DA9DE70060D2037613"
      }, 'Mojo::Cookie::Response' )
    ],
    "secure.birds.cornell.edu" => [
      bless( {
        "domain" => "secure.birds.cornell.edu",
        "host_only" => 1,
        "name" => "_0b247",
        "path" => "/",
        "value" => "http://10.0.66.20:8080"
      }, 'Mojo::Cookie::Response' ),
      bless( {
        "domain" => "secure.birds.cornell.edu",
        "host_only" => 1,
        "name" => "org.springframework.web.servlet.i18n.CookieLocaleResolver.LOCALE",
        "path" => "/",
        "samesite" => "None",
        "value" => "en_US"
      }, 'Mojo::Cookie::Response' ),
      bless( {
        "domain" => "secure.birds.cornell.edu",
        "host_only" => 1,
        "httponly" => 1,
        "name" => "JSESSIONID",
        "path" => "/cassso",
        "samesite" => "None",
        "secure" => 1,
        "value" => "ECB284A7DA4D062986323B0E8B099119"
      }, 'Mojo::Cookie::Response' ),
      bless( {
        "domain" => "secure.birds.cornell.edu",
        "expires" => 0,
        "host_only" => 1,
        "max_age" => 0,
        "name" => "CASPRIVACY",
        "path" => "/cassso",
        "samesite" => "None",
        "value" => ""
      }, 'Mojo::Cookie::Response' ),
      bless( {
        "domain" => "secure.birds.cornell.edu",
        "host_only" => 1,
        "name" => "CASTGC4",
        "path" => "/cassso",
        "samesite" => "None",
        "secure" => 1,
        "value" => "TGT-43180-L5Um2bZhfHmijtkdhlX5aUecwacLz7CO4j1mUFNhNcDdu4ar0Q-secure.birds1"
      }, 'Mojo::Cookie::Response' )
    ]
  },
  "max_cookie_size" => 4096
}, 'Mojo::UserAgent::CookieJar__WITH__Mojo::UserAgent::CookieJar::Role::Persistent' )
