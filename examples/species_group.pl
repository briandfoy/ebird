#!perl
use v5.38;
use lib qw(lib);

use eBird;

my $ebird = eBird->new;

my $species_groups = $ebird->taxonomy->groups( $ARGV[0] // 'ebird' );
say Mojo::Util::dumper($species_groups);
