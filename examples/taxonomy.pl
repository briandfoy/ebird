#!perl
use v5.38;
use lib qw(lib);

use eBird;

my $ebird = eBird->new;

my $taxa = $ebird->taxonomy->taxa;

my %categories;
foreach my $taxon ( $taxa->@* ) {
	$categories{$taxon->category}++;
	}
say Mojo::Util::dumper(\%categories);

__END__
https://science.ebird.org/en/use-ebird-data/the-ebird-taxonomy
{
  "domestic" => 25,       # domestic species
  "form" => 156,          # miscellaneous
  "hybrid" => 792,        # result of cross species breeding
  "intergrade" => 42,     # result of cross subspecies breeding
  "issf" => 3952,         # subspecies group
  "slash" => 1035,        # species pair
  "species" => 11167,     # full specification
  "spuh" => 722           # species in the genus not otherwise specified
}
