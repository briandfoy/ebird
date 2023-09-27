package eBird::Website;
use v5.38;

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

=item * get_track

=cut

sub get_track ( $self, $checklist ) {
	unless( $self->login_to_ebird() ) {

		}

	my $checklist_url = sprintf 'https://ebird.org/checklist/%s', $checklist;
	my $checklist_tx = $self->ua->get( $checklist_url );

	$checklist_tx->res->body;
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
