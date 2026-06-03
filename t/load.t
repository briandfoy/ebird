use v5.10;
use lib qw(lib blib/lib);

use Mojo::File;

=encoding utf8

=head1 NAME

t/load.t - test the taxonomy endpoint

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/load.t

=head1 DESCRIPTION

=cut

my @classes = Mojo::File->new('lib')
	->list_tree
	->grep( sub { /\.pm\z/ } )
	->map( sub { my @p = $_->to_array->@*; shift @p; $p[-1] =~ s/\.pm//; join '::', @p } )
	->to_array
	->@*;

use Test::More;

foreach my $class ( @classes ) {
	BAIL_OUT( "$class did not compile: $@\n" ) unless use_ok( $class );
	}

done_testing();

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
