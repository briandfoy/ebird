use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Command::species;
use parent qw(eBird::Command);

use namespace::autoclean;
use String::Sprintf;

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::species -  show taxonomic species information

=head1 SYNOPSIS

	% ebird species

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
	"Dealing with taxonomic species"
	}

=item * fallthrough_action

=cut

sub fallthrough_action { 'show' }

=back

=head2 Actions

=over 4

=item * action_list

=cut

sub action_list ( $self, @args ) {
	my $format = $args[0] // '%n';

	my $taxa = $self->ebird->taxonomy->taxa;
	foreach my $taxon ( $taxa->@* ) {
		my $output = $taxon->format( $format );
		next unless length $output;
		$self->cli->ebird->io->output( $output );
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

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;

__DATA__

@@ help.txt
This is the DATA section help text.
