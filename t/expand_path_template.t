use v5.36;
use Test::More 1.0;
use lib qw(lib);

my $class  = 'eBird';
my $method = 'expand_path_template';

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
