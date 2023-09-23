use v5.38;
no feature qw(module_true);

package eBird::Command::banding;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

sub description ( $self ) {
	"Dealing with eBird regions"
	}

sub run ( $self, @args ) {
	$self->cli->logger->trace("In run for region with args with <@args>");

	unless( $self->has_command($args[0]) ) {
		$self->cli->output( "region does not have a command <$args[0]>" );
		return;
		}

	$self->run_command( @args );
	}

sub command_code ( $self, @args ) {
	my $data = $self->cli->api->taxonomy_by_band( $args[0] );

	$self->cli->output( dumper($data) );
	}


__PACKAGE__;
