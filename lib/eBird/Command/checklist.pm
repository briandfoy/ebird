use v5.38;
no feature qw(module_true);

package eBird::Command::checklist;
use parent qw(eBird::Command);

use eBird::Util qw(:all);

use Mojo::Util qw(dumper);

=encoding utf8

=head1 NAME

eBird::Command::checklist -  show eBird checklists

=head1 SYNOPSIS

	% ebird checklist

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<list>.

=cut

sub default_action { 'list' }

=item * description

=cut

sub description ( $self ) {
	"Dealing with eBird checklists"
	}

=item * fallthrough_action

Returns C<view>.

=cut

sub fallthrough_action { 'view' }

=back

=head2 Actions

=over 4

=item * action_list

=cut

sub action_list ( $self, @args ) {
	my $data = $self->cli->website->fetch_checklists_summary;

	foreach my $item ( $data->@* ) {
		my $s = sprintf "% 4d %10s - %10s - %s\n",
			$item->{sequence},
			$item->{checklist},
			$item->{datetime}->strftime('%Y-%m-%d'),
			$item->{location};

		$self->cli->io->output($s);
		}
	}

=item * action_recent

=cut

# checklist recent
sub action_recent ( $self, @args ) {
	unless( looks_like_checklist($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a checklist ID" );
		return;
		}
	my $data = $self->cli->api->recent_checklists( split /-/, $args[0] );

	$self->cli->io->output( dumper($data) );
	}

=item * action_top100

=cut

# checklist top US-NY-001
# checklist top US-NY-001 today
# checklist top US-NY-001 yesterday
# checklist top US-NY-001 saturday
# checklist top US-NY-001 20230823
# checklist top US-NY-001 2023-08-23
# checklist top US-NY-001 2023/08/23
sub action_top100 ( $self, @args ) {
	my $data = $self->cli->api->subregion_data( $args[0] );

	$self->cli->io->output( dumper($data) );
	}

=item * action_top

=cut

# checklist date today
# checklist date yesterday
# checklist top US-NY-001 saturday
# checklist top US-NY-001 20230823
# checklist top US-NY-001 2023-08-23
# checklist top US-NY-001 2023/08/23
sub action_top ( $self, @args ) {
	my $data = $self->cli->api->subregion_data( $args[0] );

	$self->cli->io->output( dumper($data) );
	}

=item * action_track

=cut

sub action_track ( $self, @args ) {
	unless( looks_like_checklist_id($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a checklist ID" );
		return;
		}

	my $data = $self->cli->website->get_track( $args[0] );

	$self->cli->io->output( $data );
	}

=item * action_view

=cut

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
		$self->cli->io->error( "$args[0] does not look like a checklist ID" );
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

	$self->cli->io->output( $s );
	}

=back

=head1 TO DO


=head1 SEE ALSO

=over 4

=item * eBird terms of use - https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=item * eBird API - https://documenter.getpostman.com/view/664302/S1ENwy59

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
