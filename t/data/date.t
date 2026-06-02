use v5.38;

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../lib";

my $class = 'eBird::Data::Date';

my %summer_date = (
	year   => 2026,
	month  => 6,
	day    => 1,
	hour   => 8,
	minute => 52,
	label  => 'summer',
	);

my %winter_date = (
	year   => 2025,
	month  => 12,
	day    => 1,
	hour   => 8,
	minute => 52,
	label  => 'winter',
	);

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, qw(new);
	};

subtest 'new' => sub {
	foreach my $hash ( \%summer_date, \%winter_date ) {
		my $date = sprintf '%4d-%02d-%02d %02d:%02d', $hash->@{qw(year month day hour minute)};
		$hash->{'day_of_month'} = $hash->{'day'};
		subtest $hash->{'label'} => sub {
			my $obj = $class->new($date);
			isa_ok $obj, $class;
			can_ok $obj, qw(as_time_moment);

			subtest 'time-moment' => sub {
				my $t = $obj->as_time_moment;
				isa_ok $t, 'Time::Moment';
				diag "TM: " . $t->strftime( '%Y-%m-%dT%H:%M%z' );
				is $t->$_, $hash->{$_}, "$_ matches" for qw(year month day_of_month hour minute);
				is $obj->as_time_moment->strftime( '%z' ), '+0000', 'time zone as expected';
				};
			};
		};
	};

subtest 'with lat long' => sub {
	my $date = sprintf '%4d-%02d-%02d %02d:%02d', @summer_date{qw(year month day hour minute)};
	my $latitude  = '42.88019';
	my $longitude = '-72.761460';
	$summer_date{'day_of_month'} = $summer_date{'day'};

	my $latlong = eBird::LatLong->new_from_decimal( $latitude, $longitude );
	isa_ok $latlong, 'eBird::LatLong';

	my $obj = $class->new($date, $latlong);
	isa_ok $obj, $class;

	subtest 'time-moment' => sub {
		my $t = $obj->as_time_moment;
		isa_ok $t, 'Time::Moment';
		diag "TM: " . $t->strftime( '%Y-%m-%dT%H:%M%z' );
		is $t->$_, $summer_date{$_}, "$_ matches" for qw(year month day_of_month minute);
		is $obj->as_time_moment->strftime( '%z' ), '-0400', 'time zone as expected';

		my $expected_hour = $summer_date{'hour'} + $obj->as_time_moment->strftime( '%z' ) / 100;
		is $t->hour, $expected_hour, 'hour after offset matches';
		};
	};

done_testing();
`	`
