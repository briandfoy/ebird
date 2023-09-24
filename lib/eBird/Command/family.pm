use v5.38;
no feature qw(module_true);

package eBird::Command::family;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

sub description ( $self ) {
	"Dealing with taxonomic families"
	}

sub default_command { 'list' }

sub command_list ( $self, @args ) {
	my $data = $self->api->taxonomy;

	my %results;
	my $longest = -1;
	foreach my $item ( $data->@* ) {
		$results{$item->family_sci_name} //= $item->family_com_name;
		$longest = length $item->family_sci_name if length $item->family_sci_name > $longest;
		}

	foreach my $key ( sort keys %results ) {
		$self->cli->output( sprintf "%-*s  %s\n", $longest, $key, $results{$key} );
		}
	}

__PACKAGE__;
