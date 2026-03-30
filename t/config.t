use v5.38;
use utf8;
use lib qw(lib);

use Test::More 1.0;

use eBird;
use eBird::IO;

my $class  = 'eBird::Config';
my $method = 'new';

=encoding utf8

=head1 NAME

t/config.t - test the config

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/latlong.t

=head1 DESCRIPTION

Most of the eBird API endpoints that deal with geocoordinates want latitude
and longitude in decimal with up to two decimal places. This module handles
all of that, whether you create the object directly or from a more sophisticated
geocoordinates module.

=cut

subtest sanity => sub {
	use_ok $class;
	can_ok $class, $method, qw(new);
	} or do {
		done_testing();
		exit 1;
		};

subtest new => sub {
	my $config = $class->new;
	isa_ok $config, $class;
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

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut
