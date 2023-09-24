use v5.38;
no feature qw(module_true);

package eBird::Command::species;
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
	foreach my $item ( $data->@* ) {
		next if( defined $args[0] and $item->scientific_name !~ m/$args[0]/i );
		$results{$item->scientific_name}++;
		}

	foreach my $key ( sort keys %results ) {
		$self->cli->output( sprintf "%s\n", $key );
		}
	}

__PACKAGE__;
