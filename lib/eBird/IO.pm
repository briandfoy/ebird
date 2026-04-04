use v5.38;
use utf8;
no feature qw(module_true);

package eBird::IO;

use namespace::autoclean;
use Carp qw();
use Storable qw();

=encoding utf8

=head1 NAME

eBird::IO - generalize the output

=head1 SYNOPSIS

	use eBird;

Accept the defaults, which uses C<STDOUT> and C<STDERR> and is not quiet:

	my $io = eBird::IO->new();

	# new line is always appended
	$io->output( "We did something" );
	$io->error( "There was an error" );

	# this calls C<shortmess>
	$io->carp( "message like Carp::carp" );

Same, but quiet so no output is created:

	my $io = eBird::IO->new( quiet => 1 );

Change C<quiet> (or not) for a bit:

	$io->turn_off_quiet;  # no output
	$io->turn_on_quiet;   # can output again

Supply your own filehandles, which are any object that can respond to C<print>:

	my $io = eBird::IO->new(
		error_fh  => $fh,
		output_fh => $other_fh
		);

If you really want to be quiet and will never not be quiet. This version uses
internal filehandles that don't do anything even if C<quiet> is false:

	my $io = eBird->new_quiet;

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new(%args)

=over 4


=item * C<error_fh> - any object that can respond to C<print> (default: C<STDERR> with UTF-8)

=item * C<history> - an array ref to hold the output messages. Anything that is not an array ref disables history.

=item * C<line_ending> - the character to add to the end of any message (default: "\n")

=item * C<max_history> - the maximum number of items in the history (default: 100). The value C<0> allows unlimited history, and C<-1> disables history.

=item * C<output_fh> - any object that can respond to C<print> (default: C<STDOUT> with UTF-8)

=item * C<quiet> - any object that can respond to C<print> (default: C<STDOUT>)

=back

=cut

sub new ( $class, %args ) {
	state $rc = do {
		binmode STDOUT, ':encoding(UTF-8)';
		binmode STDERR, ':encoding(UTF-8)';
		};
	state $defaults = {
		error_fh    => \*STDERR,
		history     => [],
		line_ending => "\n",
		max_history => 100,
		output_fh   => \*STDOUT,
		quiet       => 0,
		};
	state $allowed = { map { $_, 1 } keys $defaults->%* };

	my %pass_through =
		map { $_ => $args{$_} }
		grep { exists $allowed->{$_} }
		keys %args;
	$pass_through{'quiet'} = 0 + !! $pass_through{'quiet'};

	if( exists $pass_through{'history'} and $pass_through{'history'} ne ref [] ) {
		$pass_through{'history'}     = [];
		$pass_through{'max_history'} = -1;
		}

	$pass_through{'quiet'} = 0 + !! $pass_through{'quiet'};

	my %hash = ( $defaults->%*, %pass_through );

	bless \%hash, $class;
	}

=item * new_quiet

Returns an C<eBird::IO> object where all filehandles are L<IO::Null> handles
and C<quiet> is true.

=cut

package eBird::IO::Null {
	sub new { bless {}, __PACKAGE__ }
	sub print { 1 }
	}

sub new_quiet ($class, %args) {
	state $null_fh = eBird::IO::Null->new;
	state $obj = $class->new(
		error_fh  => $null_fh,
		output_fh => $null_fh,
		quiet     => 1,
		);

	return $obj;
	}

=back

=head2 Instance methods

=over 4

=item * carp( ARRAY_OF_STRINGS )

Join ARRAY_OF_STRINGS with a newline and send to the error filehandle.

=cut

sub carp ( $self, @strings ) {
	$self->send_it( $self->error_fh, Carp::shortmess(join "\n", @strings) =~ s/\n+\z//r );
	}

=item * error( ARRAY_OF_STRINGS )

Join ARRAY_OF_STRINGS with a newline and send to the error filehandle.

=item * error_fh

Returns the filehandle that C<error> and C<carp> will use.

=cut

sub error ( $self, @strings ) {
	$self->send_it( $self->error_fh, join "\n", @strings );
	}

sub error_fh ( $self ) { $self->{'error_fh'} }

=item * history


=cut

sub history ($self) {
	Storable::dclone $self->{'history'};
	}

=item * optional_feature_needs( MODULE )

Output a message that the program needs C<MODULE>.

=cut

sub optional_feature_needs ($self, $module) {
	$self->error("Install $module to use this feature.");
	}

=item * output( ARRAY_OF_STRINGS )

Join ARRAY_OF_STRINGS with a newline and send to the standard filehandle.

=item * output_fh

Returns the filehandle that C<output> will use.

=cut

sub output ( $self, @strings ) {
	$self->send_it( $self->output_fh, join "\n", @strings );
	}

sub output_fh ( $self ) { $self->{'output_fh'} }

sub output_history ($self) {
	join $self->{'line_ending'},
	map  { $_->[1] }
	reverse
	grep { $_->[0] eq 'output' }
	$self->history->@*;
	}

=item * send_it( FILEHANDLE, MESSAGE )

The method that actually output the message. This will immediately return
is the object is set to be quiet.

If C<max_history> is not C<-1>, C<send_it> adds each message to the history, with
more recent messages at the front of the array. If C<max_history> is not C<0>,
it truncates history to that number of messages. The C<quiet> flag has no effect on
this, so you can still collect output even when quiet.

This will add the value of the C<line_ending> setting to C<MESSAGE>.

=cut

sub am_tracking_history ($self) { $self->{'max_history'} ne '-1' }
sub send_it ( $self, $fh, $string ) {
	if( $self->am_tracking_history ) {
		my $source = (caller(1))[3] =~ s/.*:://r;
		unshift $self->{'history'}->@*, [ $source, $string ];
		$self->{'history'}->$#* = ($self->{'max_history'} - 1 ) if $self->{'max_history'} and $self->{'history'}->@* > $self->{'max_history'};
		}
	return if $self->is_quiet;
	$string .= $self->{'line_ending'};
	$fh->print($string);
	}

=back

=head2 Quiet

=over 4

=item * is_quiet

Returns true if quiet is on, and false otherwise. There will be no output if
this is true, although any strings will still show up in the history.

=cut

sub is_quiet ($self) { $self->{'quiet'} }

=item * turn_off_quiet

Diasble quiet mode. This does not mean that there will be output, but that the
objects in C<error_fh> and C<output_fh> will get a change to handle the messages.

=item * turn_on_quiet

Enable quiet mode. The filehandle objects will not get a chance to handle the
messages.

=back

=cut

sub turn_off_quiet ($self) { $self->{'quiet'} = 0 }

sub turn_on_quiet ($self) { $self->{'quiet'} = 1 }

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
