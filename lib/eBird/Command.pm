use v5.38;
no feature qw(module_true);

package eBird::Command;

use experimental qw(builtin);

use builtin qw(weaken reftype);

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

sub command_to_sub ( $self, $command ) {
	"command_" . $command
	}

sub default_command { return }

sub description ( $self ) { "No description available" }

sub group ( $self ) {
	reftype($self) =~ s/.*:://r;
	}

sub has_command ($self, $command) {
	my $command_sub = $self->command_to_sub( $command );
	$self->can($command_sub);
	}

sub has_default_command ($self) {
	$self->can('default_command')
	}

sub name ($self) {
	ref($self) =~ s/.*:://r;
	}

sub run ( $self, @args ) {
	my $group = $self->group;
	$self->cli->logger->trace("In run for $group with args with <@args>");

	@args = $self->default_command if( @args == 0 and $self->has_default_command );

	unless( $self->has_command($args[0]) ) {
		$self->cli->output( "$group does not have a command <$args[0]>" );
		return;
		}

	$self->run_command( @args );
	}

sub run_command ( $self, $command, @args ) {
	my $sub = $self->has_command( $command );
	unless( defined $sub ) {
		$self->cli->error("No command subroutine for $command");
		return;
		}

	$sub->( $self, @args );
	}

__PACKAGE__;
