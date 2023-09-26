use v5.38;
no feature qw(module_true);

package eBird::Command::help;
use parent qw(eBird::Command);

=encoding utf8

=head1 NAME

eBird::Command::help - show the help message

=head1 SYNOPSIS

	% ebird help

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<show>.

=cut

sub default_action { 'show' }

=item * description

Returns the description of the command

=cut

sub description { 'show the instructions' }

=item * fallthrough_action

Returns C<show>.

=cut

sub fallthrough_action { 'show' }

=back

=head2 Actions

=over 4

=item * action_show

=cut

sub action_show ( $self ) {
	$self->cli->io->output( sprintf "%s %s\n\n", map {$self->cli->$_()} qw(name version) );

	$self->cli->io->output( "Commands\n\n" );

	foreach my $handler ( sort { $a->name cmp $b->name } $self->cli->handlers ) {
		my $string = join " - ",
			$handler->name,
			$handler->description;

		$string =~ s/^(?!\R)/\t/gm;

		$self->cli->io->output( "$string\n" );
		}
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
