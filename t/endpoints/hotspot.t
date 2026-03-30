use v5.38;
use utf8;
use lib qw(lib);

use Test::More 1.0;

my $class = 'eBird::Endpoint::Hotspot';

=encoding utf8

=head1 NAME

t/endpoints/hotspot.t - test the hotspot endpoint

=head1 SYNOPSIS

Run all the tests:

	make test

Run just the endpoint tests:

	prove t/endpoints

Run just this test:

	perl t/endpoints/hotspot.t

=head1 DESCRIPTION

=cut

subtest sanity => sub {
	use_ok $class;
	};

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

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut
