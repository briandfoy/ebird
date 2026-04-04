#!perl
use v5.38;
use lib qw(lib);

use eBird;
use eBird::Data::Taxon;


my $ebird = eBird->new;

my $locale_codes = $ebird->taxonomy->locale_codes;
say Mojo::Util::dumper($locale_codes);

foreach my $locale ( $locale_codes->@* ) {
	say "Fetching taxa for " . $locale->name;
	$ebird->taxonomy->taxa( locale => $locale->code );
	}

my $taxon = eBird::Data::Taxon->new_from_code('cangoo');

say Mojo::Util::dumper($taxon);

my $inflated = $taxon->inflate( 'sv' );
say Mojo::Util::dumper($inflated);
