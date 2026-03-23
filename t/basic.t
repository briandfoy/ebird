use v5.38;
use utf8;
use lib qw(lib);

use Test::More 1.0;

my $class = 'eBird';

=encoding utf8

=head1 NAME

t/basic.t - eBird basic object create

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/basic.t

=head1 DESCRIPTION

=cut

my @sub_methods = qw( geo hotspot obs region );

subtest sanity => sub {
	use_ok $class;
	};

subtest new => sub {
	my $ebird = $class->new;
	isa_ok $ebird, $class;
	check_object( $ebird );
	};

sub check_object ($obj) {
	foreach my $name ( @sub_methods ) {
		subtest $name => sub {
			can_ok $obj, $name;
			my $subclass = join '::', $class, 'Endpoint', "\u\L$name";
			isa_ok $obj->$name, $subclass;
			can_ok $obj->$name, qw(ebird);
			};
		}
	}

done_testing();

=back

=head1 TO DO

=head1 SEE ALSO

=over 4

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/XXX

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
