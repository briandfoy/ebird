use v5.38;
no feature qw(module_true);

package eBird::Command::tree;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::checklist -  show eBird checklists

=head1 SYNOPSIS

	% ebird checklist

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<list>.

=cut

sub default_action { 'list' }

=item * description

=cut

sub description ( $self ) {
	"Dealing with taxonomic tree"
	}

=item * fallthrough_action

Returns C<view>.

=cut

sub fallthrough_action { 'fallthrough' }

=back

=head2 Actions

=over 4

=item * action_fallthrough

=cut

sub action_fallthrough ( $self, @args ) {
	$self->action_list( @args );
	}

=item * action_list

=cut

sub action_list ( $self, @args ) {
	my $data = $self->api->taxonomy;

	my %hash;
	foreach my $item ( $data->@* ) {
		my( $order, $family, $genus, $species, $subspecies )
			= map { $item->$_() } qw(order family genus species subspecies);

		next if( defined $args[0] and $order  !~ m/$args[0]/i );
		next if( defined $args[1] and $family !~ m/$args[1]/i );
		next if( defined $args[2] and $genus  !~ m/$args[2]/i );

		$subspecies = undef if( defined $subspecies and $subspecies eq 'x' );
		no warnings qw(uninitialized);
		$hash{$order}{$family}{$genus}{$species} = $subspecies unless( defined $species and $species eq 'sp.');
		}

	foreach my $order ( sort keys %hash ) {
		$self->cli->io->output( "$order\n" );
		foreach my $family ( sort keys $hash{$order}->%* ) {
			$self->cli->io->output( "\t$family\n" );
			foreach my $genus ( sort keys $hash{$order}{$family}->%* ) {
				$self->cli->io->output( "\t\t$genus\n" );
				foreach my $species ( sort keys $hash{$order}{$family}{$genus}->%* ) {
					next unless defined $species;
					$self->cli->io->output( "\t\t\t$species\n" );
					$self->cli->io->output( "\t\t\t\t$hash{$order}{$family}{$genus}{$species}\n" ) if defined $hash{$order}{$family}{$genus}{$species};
					}
				}
			}
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
