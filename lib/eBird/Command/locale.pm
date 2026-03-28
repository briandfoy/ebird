use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Command::locale;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::locale - show taxonomic order information

=head1 SYNOPSIS

Default subcommand is C<list>:

	% ebird locale
	% ebird locale list

Add a language code to list just those:

	% ebird locale list en

Add more than one if you like:

	% ebird locale list en sv

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
	"Show the available locales"
	}

=back

=head2 Actions

=over 4

=item * action_list

=cut

sub action_list ( $self, @args ) {
	my $data = $self->ebird->taxonomy->locale_codes;

	my $alt = join '|', map { quotemeta($_) } @args;
	my $pattern = qr/^(?:$alt)/;
	foreach my $locale ( $data->@* ) {
		next unless $locale->code =~ m/$pattern/;
		my $string = sprintf '%-6s  -  %s', $locale->code, $locale->name;
		$self->cli->io->output( "$string" );
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
