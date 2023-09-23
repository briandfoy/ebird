use v5.38;
no feature qw(module_true);

package eBird::Command;

use experimental qw(builtin);

use builtin qw(weaken);

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

sub description ( $self ) {
	"No description available";
	}

sub has_command ($self, $command) {
	my $command_sub = $self->command_to_sub( $command );
	$self->can($command_sub);
	}

sub name ($self) {
	ref($self) =~ s/.*:://r;
	}

sub run ( $self ) {
	$self->cli->logger->trace("In run for version");
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
