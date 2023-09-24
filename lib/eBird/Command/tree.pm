use v5.38;
no feature qw(module_true);

package eBird::Command::tree;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

sub description ( $self ) {
	"Dealing with taxonomic families"
	}

sub default_action { 'list' }

sub fallthrough_action { 'fallthrough' }

sub action_fallthrough ( $self, @args ) {
	$self->action_list( @args );
	}

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
		$self->cli->output( "$order\n" );
		foreach my $family ( sort keys $hash{$order}->%* ) {
			$self->cli->output( "\t$family\n" );
			foreach my $genus ( sort keys $hash{$order}{$family}->%* ) {
				$self->cli->output( "\t\t$genus\n" );
				foreach my $species ( sort keys $hash{$order}{$family}{$genus}->%* ) {
					next unless defined $species;
					$self->cli->output( "\t\t\t$species\n" );
					$self->cli->output( "\t\t\t\t$hash{$order}{$family}{$genus}{$species}\n" ) if defined $hash{$order}{$family}{$genus}{$species};
					}
				}
			}
		}
	}

__PACKAGE__;
