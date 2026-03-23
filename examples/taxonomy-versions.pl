#!perl
use v5.38;
use lib qw(lib);


use eBird;

my $ebird = eBird->new;

my $tax_versions = $ebird->taxonomy->versions;
say Mojo::Util::dumper($tax_versions);

say "Latest version is " . $ebird->taxonomy->latest_version;
