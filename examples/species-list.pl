#!perl
use v5.38;
use lib qw(lib);


use eBird;

my $ebird = eBird->new;

my $region = eBird::Region->new( 'US-NY' );
printf "There are %d species\n", scalar grep { ! $_->hybrid } $ebird->product->species_in_region($region)->@*;

foreach my $species ( sort { $a->species_code cmp $b->species_code } $ebird->product->species_in_region($region)->@* ) {
	state $n = 0;
	my $inflated = $species->inflate($ebird);
	next if $inflated->is_hybrid;
	printf "%3d  %-8s -> %s\n", ++$n, $inflated->species_code, $inflated->common_name;
	}
