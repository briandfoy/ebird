use v5.38;
no feature qw(module_true);

package eBird::Command::cache;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

sub description ( $self ) {
	"interact with the cache"
	}

sub command_list ( $self ) {
	state $format = "%s      %s\n";

	$self->cli->output( <<~"HERE" );
		# Cache directory: @{[$self->api->cache_dir]}
		# EBIRD_CACHE_DIR: @{[$ENV{EBIRD_CACHE_DIR} // '<not set>']}
		# --------------------------------------------
		HERE

	my $cache_list = $self->api->list_cache;

	foreach my $item ( $cache_list->@* ) {
		my $basename = $item->[0];
		my $date = localtime( $item->[1] );
		$self->cli->output( sprintf $format, $date, $basename );
		}
	}

sub command_clear ( $self ) {
	my $cache_list = $self->api->list_cache;

	foreach my $item ( $cache_list->@* ) {
		$self->api->remove_cache_items( $item->[0] );
		$self->cli->output( "Removed $item->[0]" );
		}
	}

sub command_remove ( $self, @args ) {
	$self->api->remove_cache_items( @args );
	}

sub command_show ( $self, @args ) {
	$self->cli->output(
		$self->api->load_from_cache( $args[0] )
		);
	}

__PACKAGE__;
