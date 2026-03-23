#!perl
use v5.38;
use lib qw(lib);


use eBird;

my $ebird = eBird->new;

my $locale_codes = $ebird->taxonomy->locale_codes;
say Mojo::Util::dumper($locale_codes);

