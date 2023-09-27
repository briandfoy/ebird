package eBird::Website;
use v5.38;

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new

=cut

sub new ($class, %arguments) {
	state %defaults = (
		);

	my %required = ();
	my %options = ( %defaults, %arguments );

	my $self = bless {}, $class;
	$self->{logger} = $options{logger} // Mojo::Log->new( level => $options{log_level} );

	$self->{io} = $options{io} // eBird::IO->new;

	my @missing = grep { ! exists $options{$_} } keys %required;
	if( @missing ) {
		$self->logger->error( 'Missing keys <@missing>' );
		return;
		}

	$self->{cache} = $options{cache};

	return $self;
	}

=back

=head2

=over 4

=item *

=cut

sub create_gpx ($track_line, $start_time, $duration) {
	state $rc = require Mojo::DOM;

	my @points;
	foreach my( $lon, $lat ) ( split /,/, $track_line ) {
		push @points, {
			latitude  => 0 + $lat,
			longitude => 0 + $lon,
			};
		}
	my $point_count = @points;


	my $track_segment = Mojo::DOM->new_tag('trkseg');

	foreach my $point ( @points ) {
		my $track_point = Mojo::DOM->new_tag('trkpt');

		$track_point->at('trkpt')
			->attr( 'lat' => $point->{latitude} )
			->attr( 'lon' => $point->{longitude} )
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
		->attr( 'creator' => 'foo' )
		->append_content( $track );

	return $gpx;
	}

=item * get_track

=cut

sub get_track ( $self, $checklist ) {
	$self->logger->debug( "get_track: starting" );
	my $html = $self->get_checklist_html( $checklist );
	my $track = $self->extract_track( $html );
	$self->logger->debug( "track: @$track" );


	}

sub get_checklist_html ( $self, $checklist ) {
	unless( $self->login_to_ebird() ) {
		$self->logger->debug( "get_checklist_html: could not log into eBird" );
		return
		}

	my $checklist_url = sprintf 'https://ebird.org/checklist/%s', $checklist;
	my $checklist_tx = $self->ua->get( $checklist_url );
	$checklist_tx->res->body;
	}

sub extract_checklist {
	state $rc = require Time::Moment;
	state %months =
		map { state $n = 1; $_, $n++ }
		qw(January February March April May June July August September October November December);

	my $li = $_;

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

		{
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

sub extract_track ( $self, $html ) {
	$self->logger->debug( "extract_track: starting" );
	Mojo::DOM->new($html)
		->at( 'div#tracks-map-mini div div.Track' )
		->attr( 'data-maptrack-data' );
	}

=item * login_to_ebird

=cut

sub login_to_ebird ( $self ) {
	my( $user, $password ) = map { $self->$_() } qw(user password);
	unless( length $user and length $password ) {
		my $masked = $password =~ s/./*/gr;
		$self->logger->debug( "Need both user and password. Got <$user> and <$masked>" );
		return;
		}

	my $ua = ua();

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

	unless( $post_tx->res->is_success ) {
		die "Post failed:\n" . $post_tx->req->to_string . "\n\n" . $post_tx->res->to_string;
		}
	}

=item * password

=cut

sub password ( $self ) {  $ENV{'EBIRD_PASSWORD'} // '' }

=item * ua

=cut

sub ua {
	state $ua = do {
		state $rc = require Mojo::UserAgent;
		my $ua = Mojo::UserAgent->new;
		$ua->max_redirects(3);
		$ua->transactor->name('Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15');
		$ua;
		};
	return $ua;
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
