use v5.38;
no feature qw(module_true);

package eBird::Command;

use experimental qw(builtin);

use builtin qw(weaken);
use constant ACTION_FAILURE => 0;
use constant ACTION_SUCCESS => 1;

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new

=cut

sub new ( $class, $cli ) {
	weaken($cli);
	my %hash = (
		cli => $cli,
		);
	bless \%hash, $class;
	}

=item * register

=cut

sub register ( $class, $cli ) {
	my $self = $class->new( $cli );
	}

=back

=head2 Instance methods

=over 4

=item * cli

=cut

sub cli ($self) {
	$self->{'cli'};
	}

=item * ebird

=cut

sub ebird ($self) {
	$self->cli->{'ebird'};
	}

=item * action_to_sub

=cut

sub action_to_sub ( $self, $command ) {
	"action_" . $command
	}

=item * default_action

=cut

sub default_action { return }

=item * description

=cut

sub description ( $self ) { "No description available" }

=item * fallthrough_action

Returns C<fallthrough>, the default default.

=cut

sub fallthrough_action { 'fallthrough' }


=item * group

=cut

sub group ( $self ) {
	ref($self) =~ s/.*:://r;
	}

=item * has_action

=cut

sub has_action ($self, $action) {
	my $action_sub = $self->action_to_sub( $action );
	$self->can($action_sub);
	}

=item * has_default_action

=cut

sub has_default_action ($self) {
	defined $self->default_action;
	}

=item * has_fallthrough_action

=cut

sub has_fallthrough_action ($self) {
	defined $self->fallthrough_action;
	}

=item * name

Returns the last portion of the namespace, which for commands show be the same
as the command name.

=cut

sub name ($self) {
	ref($self) =~ s/.*:://r;
	}

=item * run

=cut

sub run ( $self, @args ) {
	my $group = ref($self);
	$self->cli->ebird->logger->debug("In run for $group with args with <@args>");

	if( @args == 0 and  $self->has_default_action ) {
		unshift @args, $self->default_action
		}
	elsif( @args > 0 and $self->has_action($args[0]) ) { () }
	elsif( $self->has_fallthrough_action ) {
		$self->cli->ebird->logger->debug("run: Selecting fallthrough");
		unshift @args, $self->fallthrough_action;
		}
	else {
		$self->cli->ebird->logger->debug("run: did not find an action");
		}

	$self->cli->ebird->logger->debug("run: args after processing are <@args>");
	my $action = $self->action_to_sub( shift @args );
	my $rc = $self->$action( @args );

	return $self->cli->exit($rc);
	}

=back

=head2 Return values

All C<action_> methods in the command modules should return a value to
indicate what happened. This will propogate up to the thing that will finally
call C<exit>.

	sub action_foo ($self, @args) {
		...
		@errors ? $self->error_value : $self->success_value;
		}

=over 4

=item * error_value

Return the value for an error exit.

=cut

sub error_value ($self) { 1 }

=item * success_value

=cut

sub success_value ($self) { 0 }

=back


=item * eBird API - https://documenter.getpostman.com/view/664302/S1ENwy59

=back

=head1 SOURCE AVAILABILITY

This source is in Github:
=head1 TO DO


=head1 SEE ALSO

=over 4

=item * eBird terms of use - https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

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
