use v5.38;
no feature qw(module_true);

package eBird::Command::band;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::band - look up banding codes

=head1 SYNOPSIS

Show all the band codes:

	% ebird band
	ABDU  American Black Duck
	...
	ZTHA  Zone-tailed Hawk

Show a particular banding code:

	% ebird band BUHU
	BUHU Bumblebee Hummingbird (Selasphorus heloisa)

Search for a banding code by a pattern. The C<^> means the banding
code must start with the partial code (or C<$> for the end>:

	% ebird band ^BU
	BUFF Bufflehead (Bucephala albeola)
	BUHU Bumblebee Hummingbird (Selasphorus heloisa)
	BUPE Bulwer's Petrel (Bulweria bulwerii)
	BULS Buller's Shearwater (Ardenna bulleri)
	BUOW Burrowing Owl (Athene cunicularia)
	BUDG Budgerigar (Melopsittacus undulatus)
	BUTU Buffy Tuftedcheek (Pseudocolaptes lawrencii)
	BUSH Bushtit (Psaltriparus minimus)
	BUOR Bullock's Oriole (Icterus bullockii)
	BURW Buff-rumped Warbler (Myiothlypis fulvicauda)

A C<.> matches any letter:

	% ebird band ZE.D
	ZEBD Zebra Dove (Geopelia striata)
	ZEND Zenaida Dove (Zenaida aurita)

=head1 DESCRIPTION

=head2 Actions

=over 4

=item * default_action()

Returns C<list>.

=cut

sub default_action { 'list' }

=item * description()

=cut

sub description ( $self ) {
	"Dealing with eBird regions"
	}

=item * fallthrough_action()

Returns C<fallthrough>.

=cut

sub fallthrough_action ( $self ) {
	'fallthrough'
	}

=back

=head2 Actions

=over 4

=item * action_fallthrough( BAND_CODE_PATTERN )

=cut

sub action_fallthrough ( $self, @args ) {
	if( $args[0] =~ /\A[A-Z0-9.^-]+\z/ ) {
		$self->action_pattern(@args);
		}
	else {
		$self->cli->io->error( "Did not understand <@args>" );
		}
}

=item * action_pattern( BAND_CODE_PATTERN )

=cut

sub action_pattern ( $self, @args ) {
	my $data = $self->api->taxonomy_by_band( $args[0] );

	foreach my $item ( $data->@* ) {
		my @codes = sort grep { /$args[0]/i } keys $item->{banding_codes}->%*;
		foreach my $code ( @codes ) {
			$self->cli->io->output( sprintf "%4s %s (%s)\n",
				$code,
				map { $item->$_() } qw(common_name scientific_name)
				);
			}
		}
	}

=item * action_list()

=cut

sub action_list ( $self, @args ) {
	my $hash = $self->api->taxonomy_all_bands;

	foreach my $key ( sort keys $hash->%* ) {
		$self->cli->io->output( sprintf "%s  %s\n", $key, $hash->{$key}{common_name} );
		}
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
