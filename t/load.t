use v5.10;
use lib qw(blib/lib);

use Mojo::File;

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
