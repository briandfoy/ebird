use v5.38;

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../lib";

my $class = 'eBird::Data::Region';

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, qw(new_from_api_response);
	};

done_testing();
