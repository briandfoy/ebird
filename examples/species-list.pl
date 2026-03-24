#!perl
use v5.38;
use lib qw(lib);


use eBird;

my $ebird = eBird->new;

my $region = eBird::Region->new( 'US-NY' )

my $tax_versions = $ebird->product->species_list($region);
say Mojo::Util::dumper($tax_versions);

say "Latest version is " . $ebird->taxonomy->latest_version;
