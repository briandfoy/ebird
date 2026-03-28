use v5.38;
use lib qw(lib);
use eBird::Config;

use eBird::Cache;

use namespace::autoclean;
use File::Spec::Functions;
use Mojo::Util qw(dumper);

my $cache_dir = eBird::Cache->new->dir->dirname;
say "DIR: $cache_dir";

my $config = eBird::Config->new( catfile( $cache_dir, 'config.toml') );

say dumper($config);

