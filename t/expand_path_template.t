use v5.36;
use Test::More 1.0;
use lib qw(lib);

my $class  = 'eBird';
my $method = 'expand_path_template';

=encoding utf8

=head1 NAME

t/expand_path_template.t -

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/expand_path_template.t

=head1 DESCRIPTION

=cut

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, $method;
	};

subtest $method => sub {
	my $obj = $class->new;
	isa_ok $obj, $class;
	can_ok $obj, $method;

	subtest 'test' => sub {
		my $path_template = '/a/b/{{foo}}/{{bar}}';
		my $expected      = '/a/b/123/xyz';
		my $args = {
			foo => 123,
			bar => 'xyz',
			};

		my $munged = $obj->$method( $path_template, $args );
		is $munged, $expected, "got the right thing";
		};
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
