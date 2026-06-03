use v5.38;

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../lib";

my $class = 'eBird::Nearby';
my $method = 'closest';

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, qw(closest);
	};

subtest 'closest' => sub {
	my $hotspot = $class->$method( $latlong );
	};

done_testing();
