use v5.38;
no feature qw(module_true);

package eBird::Command::checklist;
use parent qw(eBird::Command);

use eBird::Util qw(:all);

use Mojo::Util qw(dumper);

sub fallthrough_action { 'view' }

# checklist recent
sub action_recent ( $self, @args ) {
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
sub action_top100 ( $self, @args ) {

	my $data = $self->cli->api->subregion_data( $args[0] );

	$self->cli->output( dumper($data) );
	}

# checklist date today
# checklist date yesterday
# checklist top US-NY-001 saturday
# checklist top US-NY-001 20230823
# checklist top US-NY-001 2023-08-23
# checklist top US-NY-001 2023/08/23
sub action_top ( $self, @args ) {
	my $data = $self->cli->api->subregion_data( $args[0] );

	$self->cli->output( dumper($data) );
	}

# checklist view

=pod

  3 rocpig1
  4 moudov
  1 rthhum
  1 doccor
  1 reevir1
  1 grycat
  3 amerob
 25 houspa
  1 whtspa
  1 norpar
  1 magwar

=cut

sub action_view ( $self, @args ) {
	unless( looks_like_checklist_id($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a checklist ID" );
		return;
		}

	my $checklist = $self->cli->api->view_checklist( $args[0] );

	my $s = <<~"HERE";
	Birder:  @{[ $checklist->birder ]}
	started: @{[ $checklist->time_started ]}

	HERE

	$s .= join "\n",
		map { sprintf "%3d %s", $_->count, $self->api->species_code_to_common_name($_->species_code) }
		$checklist->observations->@*;

	$self->cli->output( $s );
	}

__PACKAGE__;
