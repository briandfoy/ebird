use v5.38;
no feature qw(module_true);

package eBird::Command::version;
use parent qw(eBird::Command);

=encoding utf8

=head1 NAME

eBird::Command::version - show version information

=head1 SYNOPSIS

	% ebird version

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<show>.

=cut

sub default_action { 'show' }

=item * description

=cut

sub description ( $self ) {
	"show the version"
	}

=item * fallthrough_action

=cut

sub fallthrough_action { 'show' }

=back

=head2 Actions

=over 4

=item * action_show

=cut

sub action_show ( $self ) {
	$self->cli->logger->trace("In run for version");
	$self->cli->output( "version " . $self->cli->version );
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
