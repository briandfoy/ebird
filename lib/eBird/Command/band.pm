use v5.38;
no feature qw(module_true);

package eBird::Command::band;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=head1 NAME

eBrid::Command::band

=head1 SYNOPSIS

Show all the band codes:

	% ebird band


=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_command

Returns C<list>.

=cut

sub default_action { 'list' }

=item * description

=cut

sub description ( $self ) {
	"Dealing with eBird regions"
	}

sub fallthrough_action ( $self ) {
	'fallthrough'
	}

=head2 Actions

=over 4

=item * action_fallthrough

=cut

sub action_fallthrough ( $self, @args ) {
	if( $args[0] =~ /\A[A-Z0-9.^-]+\z/ ) {
		$self->action_pattern(@args);
		}
	else {
		$self->cli->error( "Did not understand <@args>" );
		}
}

=item * action_pattern

=cut

sub action_pattern ( $self, @args ) {
	my $data = $self->api->taxonomy_by_band( $args[0] );

	foreach my $item ( $data->@* ) {
		my @codes = sort grep { /$args[0]/i } keys $item->{banding_codes}->%*;
		foreach my $code ( @codes ) {
			$self->cli->output( sprintf "%4s %s (%s)\n",
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
		$self->cli->output( sprintf "%s  %s\n", $key, $hash->{$key}{common_name} );
		}
	}

__PACKAGE__;
