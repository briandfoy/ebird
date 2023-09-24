use v5.38;
no feature qw(module_true);

package eBird::Command::region;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

sub description ( $self ) {
	"Dealing with eBird regions"
	}

sub action_adjacent ( $self, @args ) {
	unless( looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->adjacent_regions( split /-/, $args[0] );

	$self->cli->output( dumper($data) );
	}

sub action_info ( $self, @args ) {
	unless( looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->region_info_for( $args[0] );

	$self->cli->output( dumper($data) );
	}

sub action_list ( $self, @args ) {
	if( @args and ! looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->subregion_data( @args );

	$self->cli->output( dumper($data) );
	}


__PACKAGE__;
