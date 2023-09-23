use v5.38;
no feature qw(module_true);

package eBird::Command::hotspot;
use parent qw(eBird::Command);

use eBird::Util qw(:all);

use Mojo::Util qw(dumper);

sub run ( $self, @args ) {
	$self->cli->logger->trace("In run for hotspot with args with <@args>");

	unless( $self->has_command($args[0]) ) {
		$self->cli->output( "region does not have a command <$args[0]>" );
		return;
		}

	$self->run_command( @args );
	}

# hotspot info L299148
sub command_info ( $self, @args ) {
	my $data = $self->cli->api->hotspot_info( $args[0] );
	unless( keys $data->%* ) {
		$self->cli->error( "There is no information for hotspot <$args[0]>" );
		return;
		}

	$self->cli->output( dumper($data) );
	}

# hotspot list US
# hotspot list US-NY
# hotspot list US-NY-001
sub command_list ( $self, @args ) {
	my $data = $self->cli->api->hotspots_in_region( $args[0] );

	my %hash = map { $_->id, $_->name } $data->@*;

	$self->cli->output( dumper($data) );
	}


# hotspot near L299148
# hotspot near L299148 --distance 25
# hotspot near --latitude ... --longitude ...
# hotspot near --latitude ... --longitude ... --distance 5
sub command_near ( $self, @args ) {
	my %args;
	if( matches_hotspot_id($args[0]) ) {
		my $id = shift @args;
		my $data = $self->cli->api->hotspot_info( $id );
		unless( keys $data->%* ) {
			$self->cli->error( "There is no information for hotspot <$id>" );
			return;
			}

		$args{'--latitude'} = $data->latitude;
		$args{'--longitude'} = $data->longitude;
		$args{'--distance'} //= 25;
		}

	$self->cli->logger->debug( "Args: " . dumper(\%args) );

	my @errors;
	push @errors, "--latitude is missing" unless exists $args{'--latitude'};
	push @errors, "--longitude is missing" unless exists $args{'--longitude'};

	if( @errors ) {
		$self->cli->error( join "\n", @errors );
		return;
		}

	push @errors, "--latitude is out of range: -90 <= lat <= 90"
		unless latitude_in_range( $args{'--latitude'}  );
	push @errors, "--longitude is out of range: -180 <= long <= 180"
		unless longitude_in_range( $args{'--longitude'} );
	push @errors, "--distance is out of range: 0 <= dist <= 500"
		if( exists $args{'--distance'} and ! (0 <= $args{'--distance'} <= 500) );

	if( @errors ) {
		$self->cli->error( join "\n", @errors );
		return;
		}



	my $data = $self->cli->api->nearby_hotspots(
		$args{'--latitude'} ,
		$args{'--longitude'},
		$args{'--distance'},
		);

	my %hash = map { $_->id, $_->name } $data->@*;

	$self->cli->output( dumper(\%hash) );
	}

__PACKAGE__;
