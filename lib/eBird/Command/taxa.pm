use v5.38;
no feature qw(module_true);

package eBird::Command::taxa;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

sub description ( $self ) {
	"Dealing with eBird regions"
	}

sub default_action { 'list' }

sub action_list ( $self ) {
	my $data = $self->cli->api->taxonomy;

	$self->cli->output( dumper($data) );
	}

sub action_locales ( $self, @args ) {
	my $data = $self->cli->api->taxa_locales;

	$self->cli->output( dumper($data) );
	}

sub action_groups ( $self, %args ) {
	$args{locale}   //= 'en';
	$args{grouping} //= 'ebird';

	my $data = $self->cli->api->taxa_groups(%args);

	$self->cli->output( dumper($data) );
	}

sub action_versions ( $self, @args ) {
	my $data = $self->cli->api->taxa_versions;

	$self->cli->output( dumper($data) );
	}

__PACKAGE__;
