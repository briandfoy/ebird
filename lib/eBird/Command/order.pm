use v5.38;
no feature qw(module_true);

package eBird::Command::order;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

sub description ( $self ) {
	"Dealing with taxonomic orders"
	}

sub default_command { 'list' }

sub command_list ( $self, @args ) {
	my $data = $self->api->taxonomy;

	my %results;
	my $longest = -1;
	foreach my $item ( $data->@* ) {
		$results{$item->order}++;
		}

	foreach my $key ( sort keys %results ) {
		$self->cli->output( $key . "\n" );
		}
	}

__PACKAGE__;
