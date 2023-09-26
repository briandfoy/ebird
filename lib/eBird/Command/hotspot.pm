use v5.38;
no feature qw(module_true);

package eBird::Command::hotspot;
use parent qw(eBird::Command);

use eBird::Util qw(:all);

use Mojo::Util qw(dumper);

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Actions

=over 4

=item * action_info

=cut

# hotspot info L299148
sub action_info ( $self, @args ) {
	my $data = $self->cli->api->hotspot_info( $args[0] );
	unless( keys $data->%* ) {
		$self->cli->io->error( "There is no information for hotspot <$args[0]>" );
		return;
		}

	$self->cli->io->output( dumper($data) );
	}

=item * action_list

=cut

# hotspot list US
# hotspot list US-NY
# hotspot list US-NY-001
sub action_list ( $self, @args ) {
	my $data = $self->cli->api->hotspots_in_region( $args[0] );

	my %hash = map { $_->id, $_->name } $data->@*;

	$self->cli->io->output( dumper($data) );
	}

=item * action_near

=cut

# hotspot near L299148
# hotspot near L299148 --distance 25
# hotspot near --latitude ... --longitude ...
# hotspot near --latitude ... --longitude ... --distance 5
sub action_near ( $self, @args ) {
	my %args;
	if( matches_hotspot_id($args[0]) ) {
		my $id = shift @args;
		my $data = $self->cli->api->hotspot_info( $id );
		unless( keys $data->%* ) {
			$self->cli->io->error( "There is no information for hotspot <$id>" );
			return;
			}

		say dumper($data);

		$args{'--latitude'} = $data->latitude;
		$args{'--longitude'} = $data->longitude;
		$args{'--distance'} //= 25;
		}

	$self->cli->logger->debug( "Args: " . dumper(\%args) );

	my @errors;
	push @errors, "--latitude is missing" unless exists $args{'--latitude'};
	push @errors, "--longitude is missing" unless exists $args{'--longitude'};

	if( @errors ) {
		$self->cli->io->error( join "\n", @errors );
		return;
		}

	push @errors, "--latitude is out of range: -90 <= lat <= 90"
		unless latitude_in_range( $args{'--latitude'}  );
	push @errors, "--longitude is out of range: -180 <= long <= 180"
		unless longitude_in_range( $args{'--longitude'} );
	push @errors, "--distance is out of range: 0 <= dist <= 500"
		if( exists $args{'--distance'} and ! (0 <= $args{'--distance'} <= 500) );

	if( @errors ) {
		$self->cli->io->error( join "\n", @errors );
		return;
		}



	my $data = $self->cli->api->nearby_hotspots(
		$args{'--latitude'} ,
		$args{'--longitude'},
		$args{'--distance'},
		);

	my %hash = map { $_->id, $_->name } $data->@*;

	$self->cli->io->output( dumper(\%hash) );
	}

=back

=head1 TO DO


=head1 SEE ALSO

=over 4

=item * eBird terms of use - https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=item * eBird API - https://documenter.getpostman.com/view/664302/S1ENwy59

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
