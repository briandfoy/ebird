use v5.38;
use utf8;
use FindBin qw($Bin);
use lib ('lib', "$Bin/../lib");

use Test::More 1.0;

use File::Basename;
my $command = basename(__FILE__) =~ s/\.t\z//r;

=encoding utf8

=head1 NAME

t/command/band.t -

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/command/band.t

=head1 DESCRIPTION

=cut

require 'command_test_utils.pl';

clear_env();

my $CLI = make_cli();

help_shows_command( $CLI, $command );

done_testing();

=back

=head1 TO DO

=head1 SEE ALSO

=over 4

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
