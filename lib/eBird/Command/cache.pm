use v5.38;
no feature qw(module_true);

package eBird::Command::cache;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

=encoding utf8

=head1 NAME

eBird::Command::cache - interact with the application cache

=head1 SYNOPSIS

List all the things in the cache

	% ebird cache list
	# Cache directory: /Users/brian/.ebird-perl
	# EBIRD_CACHE_DIR: <not set>
	# --------------------------------------------
	Sat Sep 23 22:33:09 2023      checklist-S137137137
	Sat Sep 23 14:54:47 2023      countries
	Sat Sep 23 17:54:13 2023      hotspots-US-NY-109
	Sat Sep 23 14:59:51 2023      subnational-FJ
	Sat Sep 23 15:26:31 2023      subnational-US
	Sat Sep 23 15:19:31 2023      subnational2-FJ-C
	Sat Sep 23 15:26:35 2023      subnational2-US-NY
	Sat Sep 23 23:14:45 2023      taxonomy-en

Remove an item. This means the next time that you need that resource,
B<ebird> will fetch it through the eBird API.

	% ebird cache rm checklist-S137137137

Remove all the items:

	% ebird cache clear

Show the contents of a cache item (which is raw data):

	% ebird cache show checklist-S137137137

=head1 DESCRIPTION

=head2 Actions

=over 4

=item * description

Returns the description of the command

=cut

sub description ( $self ) {
	"interact with the cache"
	}

=item * default_action

Returns C<list>.

=cut

sub default_action ( $self ) { 'list' }

=item * action_clear

=cut

sub action_clear ( $self ) {
	my $cache_list = $self->api->list_cache;

	foreach my $item ( $cache_list->@* ) {
		$self->cli->cache->remove( $item->[0] );
		$self->cli->io->output( "Removed $item->[0]" );
		}
	}

=item * action_list

=cut

sub action_list ( $self ) {
	state $format = "%s      %s\n";

	$self->cli->io->output( <<~"HERE" );
		# Cache directory: @{[$self->cli->cache->dir]}
		# EBIRD_CACHE_DIR: @{[$ENV{EBIRD_CACHE_DIR} // '<not set>']}
		# --------------------------------------------
		HERE

	foreach my $item ( $self->cli->cache->list->@* ) {
		my $date = localtime( $item->[1] );
		$self->cli->io->output( sprintf $format, $date, $item->[0] );
		}
	}

=item * action_open

=cut

sub action_open ( $self, @args ) {
	my( $file ) = @args;

	my $path = $self->cli->cache->path( $file );
	unless( -e $path ) {
		$self->cli->logger->error( "There is no <$file> in the cache" );
		return;
		}

	if( length $ENV{EDITOR} ) {
		my $rc = system $ENV{EDITOR}, $path;
		if( $rc == -1 ) {
			$self->cli->logger->error( "Could not open file with <$ENV{EDITOR}>" );
			return;
			}
		return $rc;
		}
	else {
		my @command = do {
			   if( length $ENV{EDITOR} ) { $ENV{EDITOR} }
			elsif( $^O eq 'windows' ) { 'cmd.exe /c start ""' }
			elsif( -x `which xdg-open` =~ s/\R+//r ) { 'xdg-open' }
			elsif( -x `which open` =~ s/\R+//r ) { 'open' }
			};
		push @command, "$path";
		my $rc = system { $command[0] } @command;
		if( $rc == -1 ) {
			$self->cli->logger->error( "Could not open <$path> with <$command[0]>" );
			return;
			}

		return $rc
		}

	}

=item * action_remove

=cut

sub action_remove ( $self, @args ) {
	$self->cli->cache->remove( @args );
	}

=item * action_show

=cut

sub action_show ( $self, @args ) {
	$self->cli->io->output(
		$self->cli->cache->load( $args[0] )
		);
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
