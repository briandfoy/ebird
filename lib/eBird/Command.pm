use v5.38;
no feature qw(module_true);

package eBird::Command;

use experimental qw(builtin);

use builtin qw(weaken);
use constant ACTION_FAILURE => 0;
use constant ACTION_SUCCESS => 1;

sub new ( $class, $cli ) {
	weaken($cli);
	my %hash = (
		cli => $cli,
		);
	bless \%hash, $class;
	}

sub register ( $class, $cli ) {
	my $self = $class->new( $cli );
	}

sub cli ($self) {
	$self->{cli};
	}

sub api ($self) {
	$self->{cli}{api};
	}

sub action_to_sub ( $self, $command ) {
	"action_" . $command
	}

sub default_action { return }

sub description ( $self ) { "No description available" }

sub fallthrough_action { return }

sub group ( $self ) {
	ref($self) =~ s/.*:://r;
	}

sub has_action ($self, $action) {
	my $action_sub = $self->action_to_sub( $action );
	$self->can($action_sub);
	}

sub has_default_action ($self) {
	defined $self->default_action;
	}

sub has_fallthrough_action ($self) {
	defined $self->fallthrough_action;
	}

sub name ($self) {
	ref($self) =~ s/.*:://r;
	}

sub run ( $self, @args ) {
	my $group = ref($self);
	$self->cli->logger->debug("In run for $group with args with <@args>");
	$self->cli->logger->debug("run: args are <@args>");

	$self->cli->logger->debug("run: has fallthrough => " . $self->has_fallthrough_action);

	if( @args == 0 and  $self->has_default_action ) {
		unshift @args, $self->default_action
		}
	elsif( @args > 0 and $self->has_action($args[0]) ) { () }
	elsif( $self->has_fallthrough_action ) {
		$self->cli->logger->debug("run: Selecting fallthrough");
		unshift @args, $self->fallthrough_action;
		}
	else {
		$self->cli->logger->debug("run: did not find an action");
		}

	$self->cli->logger->debug("run: args are <@args>");
	my $action = $self->action_to_sub( shift @args );
	$self->$action( @args );

	return ACTION_SUCCESS;
	}


__PACKAGE__;
