use v5.38;
no feature qw(module_true);

package eBird::Command::region;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::region - show region information

=head1 SYNOPSIS

	% ebird region

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<show>.

=cut

sub default_action { 'list' }

=item * description

=cut

sub description ( $self ) {
	"Dealing with eBird regions"
	}

=back

=head2 Actions

=over 4

=item * action_adjacent( REGION )

=cut

sub action_adjacent ( $self, @args ) {
	unless( looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->adjacent_regions( split /-/, $args[0] );

	$self->cli->output( dumper($data) );
	}

=item * action_info( REGION )

=cut

sub action_info ( $self, @args ) {
	unless( looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->region_info_for( $args[0] );

	$self->cli->output( dumper($data) );
	}

=item * action_list( REGION )

=cut

sub action_list ( $self, @args ) {
	if( @args and ! looks_like_region($args[0]) ) {
		$self->cli->error( "$args[0] does not look like a region" );
		return;
		}

	my $data = $self->cli->api->subregion_data( @args );

	$self->cli->output( dumper($data) );
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
