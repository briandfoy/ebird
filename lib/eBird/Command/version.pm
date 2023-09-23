use v5.38;
no feature qw(module_true);

package eBird::Command::version;
use parent qw(eBird::Command);

sub run ( $self ) {
	$self->cli->logger->trace("In run for version");
	$self->cli->output( "version " . $self->cli->version );
	}

__PACKAGE__;
