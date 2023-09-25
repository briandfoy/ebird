use Test::More;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;

my $also_private = [
	qr/\AATTRIBUTE_/,
	];

my $trust_me = [
	qr/\AATTRIBUTE_/,
	];

all_pod_coverage_ok({
	trust_me     => $trust_me,
	also_private => $also_private,
});

