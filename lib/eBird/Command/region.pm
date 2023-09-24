use v5.38;
no feature qw(module_true);

package eBird::Command::region;
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

sub command_adjacent ( $self, @args ) {
	unless( looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->adjacent_regions( split /-/, $args[0] );

	$self->cli->output( dumper($data) );
	}

sub command_info ( $self, @args ) {
	unless( looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->region_info_for( $args[0] );

	$self->cli->output( dumper($data) );
	}

sub command_list ( $self, @args ) {
	if( @args and ! looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->subregion_data( @args );

	$self->cli->output( dumper($data) );
	}


__PACKAGE__;