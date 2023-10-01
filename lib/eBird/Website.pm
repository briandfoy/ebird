package eBird::Website;
use v5.38;
no feature qw(module_true);

use experimental qw(builtin for_list);

use builtin qw(ceil);

use Mojo::DOM;
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Util qw(dumper);
use Time::Moment;

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new

	- logger
	- cache
	- io

=cut

sub new ($class, %arguments) {
	state %defaults = (
		);

	my %required = ();
	my %options = ( %defaults, %arguments );

	my $self = bless {}, $class;
	$self->{logger} = $options{logger} // Mojo::Log->new( level => $options{log_level} );

	$self->{io} = $options{io} // eBird::IO->new;

	$self->{cache} = $options{cache} // eBird::Cache->new;

	my @missing = grep { ! exists $options{$_} } keys %required;
	if( @missing ) {
		$self->logger->error( 'Missing keys <@missing>' );
		return;
		}

	$self->{cache} = $options{cache};

	return $self;
	}

sub logger ($self) { $self->{logger} }
sub cache  ($self) { $self->{cache} }
sub io     ($self) { $self->{io} }

=back

=head2 Instance methods

=over 4

=item * create_gpx

=cut

sub create_gpx ($self, $hash) {
	$self->logger->debug( "create_gpx: starting" );
	$self->logger->debug( "create_gpx: hash: " . dumper($hash) );

	my $start_tm = Time::Moment->new(
		$hash->%{qw(year month day hour minute)},
		offset => $hash->{'timezonedb'}{'gmtOffset'} / 3600,
		);

	my $interval = $hash->{'seconds'} / $hash->{'track'}->@*;
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

	my $hour  = $+{hour} + ($+{meridian} eq 'PM' ? 12 : 0);
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

=item * fetch_checklists_summary

=cut

sub fetch_checklists_summary ( $self ) {
	unless( $self->login_to_ebird() ) {
		$self->logger->debug( "fetch_checklists_summary: could not log into eBird" );
		return
		}

	# https://ebird.org/mychecklists?currentRow=1&sortBy=date&o=desc
	my $params = {
		currentRow => 1,
		sortBy     => 'date',
		o          => 'desc',
		};

	my @checklists;
	my $expected_pages = 1;
	my $page = 0;
	my $per_page = 100;

	while( $page <= $expected_pages ) {
		$page++;

		$self->logger->debug( "Fetching page <$page> of <$expected_pages>" );

		my $html = $self->fetch_list_page( $page, $per_page );

		push @checklists, Mojo::DOM->new($html)->find( 'li[id^="checklist-"]' )
			->map( \&_extract_item_details )
			->to_array
			->@*;

		state $n = do {
			$per_page = @checklists;
			$self->logger->debug( "per page is <$per_page>" );
			my $highest = $checklists[0]->{sequence};
			$self->logger->debug( "Highest checklist is <$highest>" );
			$expected_pages = ceil( $highest / $per_page );
			$self->logger->debug( "Expected pages is <$expected_pages>" );
			};
		}

	return \@checklists;
	}

=item * fetch_list_page

=cut

sub fetch_list_page ( $self, $page, $per_page = 100 ) {
	my $params = {
		currentRow => ($per_page * ($page-1)) + 1,
		sortBy     => 'date',
		o          => 'desc',
		};

	my $cache_key = "website-checklist-page-$page";
	my $data = $self->cache->load( $cache_key );
	return $data if defined $data;

	my $checklists_tx = $self->ua->get( 'https://ebird.org/mychecklists' => form => $params );
	my $html = $checklists_tx->res->body;

	$self->cache->save( $cache_key, $html );

	return $html;
	}

=item * login_to_ebird

=cut

sub login_to_ebird ( $self ) {
	$self->logger->debug( "login_to_ebird: starting" );

	my( $user, $password ) = map { $self->$_() } qw(user password);
	unless( length $user and length $password ) {
		my $masked = $password =~ s/./*/gr;
		$self->logger->debug( "Need both user and password. Got <$user> and <$masked>" );
		return;
		}

	my $ua = $self->ua;
	# $self->logger->debug( "login_to_bird: before login cookies are " .dumper( $ua->cookie_jar ) );

	foreach my $cookie ( $ua->cookie_jar->find(Mojo::URL->new("https://secure.birds.cornell.edu/cassso"))->@* ) {
		$self->logger->debug( sprintf "login_to_ebird: cookie %s => %s", $cookie->name, $cookie->value );
		if( $cookie->name eq 'JSESSIONID' ) {
			$self->logger->debug( "login_to_ebird: found JSESSIONID, so assuming we're logged in" );
			return 1;
			}
		}

	$self->logger->debug( "login_to_ebird: did not find JSESSIONID, so logging in" );

	$ua->get( 'https://ebird.org/home' );
	my $tx = $ua->get( 'https://ebird.org/home?forceLogin=true' );

	my $location = Mojo::URL->new( $tx->req->url )->query(Mojo::Parameters->new);

	$self->logger->debug(  "Location: " . $location );

	my $form = $tx->res->dom->at( 'form#credentials' );

	my $action = $form->attr( 'action' );

	my $action_url = $location->clone->path( $action );
	$self->logger->debug( "ACTION URL $action_url" );

	my $params = {
		username   => $user,
		password   => $password,
		'lt'       => $form->at( 'input[name=lt]' )->attr( 'value' ),
		execution  => $form->at( 'input[name=execution]' )->attr( 'value' ),
		'_eventId' => $form->at( 'input[name=_eventId]' )->attr( 'value' ),
		submit     => 'Sign in',
		};

	my $headers = {
		'Referer' => $location,
		};

	$action_url = 'https://secure.birds.cornell.edu/cassso/login';

	my $post_tx = $ua->post( $action_url => $headers => form => $params );
	$self->logger->debug( "login_to_bird: response code is\n--------\n" . $tx->res->headers->to_string . "\n------\n" );

	unless( $post_tx->res->is_success ) {
		$self->{logged_in} = 0;
		die "Post failed:\n" . $post_tx->req->to_string . "\n\n" . $post_tx->res->to_string;
		}

	$self->ua->cookie_jar->save;

	$self->{logged_in} = 1;

	}

=item * password

=cut

sub password ( $self ) {  $ENV{'EBIRD_PASSWORD'} // '' }

=item * ua

=cut

sub ua ($self) {
	state $ua = do {
		state $rc = require Mojo::UserAgent;
		my $ua = Mojo::UserAgent->new;
		$ua->cookie_jar->with_roles('+Persistent')->load;
		$ua->max_redirects(3);
		$ua->transactor->name('Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15');
		$ua;
		};
	return $self->{ua} = $ua;
	}

=item * user

=cut

sub user ( $self ) { $ENV{'EBIRD_USER'} // '' }

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
