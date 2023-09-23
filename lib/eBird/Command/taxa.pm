use v5.38;
no feature qw(module_true);

package eBird::Command::taxa;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

sub description ( $self ) {
	"Dealing with eBird regions"
	}

sub run ( $self, @args ) {
	$self->cli->logger->trace("In run for region with args with <@args>");

	unless( $self->has_command($args[0]) ) {
		$self->cli->output( "region does not have a command <$args[0]>" );
		return;
		}

	$self->run_command( @args );
	}

sub command_list ( $self ) {
	my $data = $self->cli->api->taxonomy;

	$self->cli->output( dumper($data) );
	}

sub command_locales ( $self, @args ) {
	my $data = $self->cli->api->taxa_locales;

	$self->cli->output( dumper($data) );
	}

sub command_groups ( $self, %args ) {
	$args{locale}   //= 'en';
	$args{grouping} //= 'ebird';

	my $data = $self->cli->api->taxa_groups(%args);

	$self->cli->output( dumper($data) );
	}

sub command_versions ( $self, @args ) {
	my $data = $self->cli->api->taxa_versions;

	$self->cli->output( dumper($data) );
	}

__PACKAGE__;
