use v5.38;
no feature qw(module_true);

package eBird::Command::taxa;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::taxa - show overall taxonomic information

=head1 SYNOPSIS

	% ebird taxa
	Acanthisittidae     New Zealand Wrens
	Acanthizidae        Thornbills and Allies
	Accipitridae        Hawks, Eagles, and Kites
	...

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
	"Dealing with eBird taxonomies"
	}

=back

=head2 Actions

=over 4

=item * action_list

=cut

sub action_list ( $self ) {
	my $data = $self->cli->api->taxonomy;

	$self->cli->io->output( dumper($data) );
	}

=item * action_locales

=cut

sub action_locales ( $self, @args ) {
	my $data = $self->cli->api->taxa_locales;

	$self->cli->io->output( dumper($data) );
	}

=item * action_groups

=cut

sub action_groups ( $self, %args ) {
	$args{locale}   //= 'en';
	$args{grouping} //= 'ebird';

	my $data = $self->cli->api->taxa_groups(%args);

	$self->cli->io->output( dumper($data) );
	}

=item * action_versions

=cut

sub action_versions ( $self, @args ) {
	my $data = $self->cli->api->taxa_versions;

	$self->cli->io->output( dumper($data) );
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
