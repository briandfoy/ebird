use v5.38;
no feature qw(module_true);

package eBird::Command::checklist;
use parent qw(eBird::Command);

use eBird::Util qw(:all);

use Mojo::Util qw(dumper);

sub run ( $self, @args ) {
	$self->cli->logger->trace("In run for region with args with <@args>");

	unless( $self->has_command($args[0]) ) {
		$self->cli->output( "region does not have a command <$args[0]>" );
		return;
		}

	$self->run_command( @args );
	}


# checklist recent
sub command_recent ( $self, @args ) {
	unless( looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}
	my $data = $self->cli->api->recent_checklists( split /-/, $args[0] );

	$self->cli->output( dumper($data) );
	}

# checklist top US-NY-001
# checklist top US-NY-001 today
# checklist top US-NY-001 yesterday
# checklist top US-NY-001 saturday
# checklist top US-NY-001 20230823
# checklist top US-NY-001 2023-08-23
# checklist top US-NY-001 2023/08/23
sub command_top100 ( $self, @args ) {

	my $data = $self->cli->api->subregion_data( $args[0] );

	$self->cli->output( dumper($data) );
	}

# checklist date today
# checklist date yesterday
# checklist top US-NY-001 saturday
# checklist top US-NY-001 20230823
# checklist top US-NY-001 2023-08-23
# checklist top US-NY-001 2023/08/23
sub command_top ( $self, @args ) {
	my $data = $self->cli->api->subregion_data( $args[0] );

	$self->cli->output( dumper($data) );
	}

# checklist view
sub command_view ( $self, @args ) {
	unless( looks_like_checklist_id($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a checklist ID" );
		return;
		}

	my $data = $self->cli->api->view_checklist( $args[0] );

	$self->cli->output( dumper($data) );

	}

__PACKAGE__;
