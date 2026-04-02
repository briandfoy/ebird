use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Command::db;
use parent qw(eBird::Command);

use namespace::autoclean;
use Mojo::Util qw(dumper);

use eBird::SQLite;
use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::db - interact with the SQLite database

=head1 SYNOPSIS

Show all the band codes:

	% ebird db init

=head1 DESCRIPTION

=head2 Actions

=over 4

=item * default_action()

Returns C<list>.

=cut

sub default_action { 'init' }

=item * description()

=cut

sub description ( $self ) {
	"Dealing with local SQLite database"
	}

=back

=head2 Actions

=over 4

=item * action_delete()

=cut

sub action_delete ( $self, @args ) {
	$self->cli->ebird->io->output( 'Deleting database' );
	my $ebird_db = eBird::SQLite->new( 'ebird.db', $self->ebird );
	my $path = $ebird_db->path;
	$self->cli->ebird->io->output( "Path is $path" );
	unlink $path;
	}

=item * action_fallthrough()

=cut

sub action_fallthrough ( $self, @args ) { 'init' }

=item * action_init()

=cut

sub action_init ( $self, @args ) {
	unless( eBird::Util::has_sqlite() ) {
		$self->cli->ebird->io->optional_feature_needs('SQLite');
		return;
		}

	$self->cli->ebird->io->output( 'Init database' );
	my $ebird_db = eBird::SQLite->new( 'ebird.db', $self->ebird );
	$ebird_db->init;

	$self->cli->ebird->io->output( 'Database initialized' );
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

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;

__END__
