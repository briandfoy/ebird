use v5.38;
no feature qw(module_true);

package eBird::Command::track;
use parent qw(eBird::Command);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::track - extract a track from one of your checklists

=head1 SYNOPSIS

	% ebird track

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<show>.

=cut

sub default_action { 'fallthrough' }

=item * description

=cut

sub description ( $self ) {
	"extract GPS tracks from checklists"
	}

=item * fallthrough_action

=cut

sub fallthrough_action { 'fallthrough' }

=back

=head2 Actions

=over 4

=item * action_show

=cut

sub action_fallthrough ( $self, @args ) {
	$self->cli->logger->trace("In fallthough for track");
	$self->cli->io->output( "track " . $self->cli->version );

	unless( looks_like_checklist_id($args[0]) ) {
		$self->cli->io->error( "<$args[0]> does not look like a checklist" );
		return;
		}

	$self->website->get(

		);
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
