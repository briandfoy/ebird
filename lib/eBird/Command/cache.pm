use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Command::cache;
use parent qw(eBird::Command);

use namespace::autoclean;
use File::Spec::Functions;
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

=item * action_clear( [-n], [PATTERN] )

Remove every cache item.

Note that many things will recreate all the items they need, which might
heavily hit the eBird API.

If the first argument is C<-n>, then no items are removed but the output will
show what would be removed.

=cut

sub action_clear ( $self, @args ) {
	my $cache_list = $self->ebird->cache->list;

	my $dry_run = 0;
	if( $args[0] eq '-n' ) {
		$dry_run = 1;
		shift @args;
		}

	my $pattern = qr/./;
	if( @args ) {
		$pattern = eval { qr/$args[0]/ };
		unless( defined $pattern ) {
			$self->cli->ebird->io->error( "Invalid pattern <$args[0]>" );
			$self->cli->exit_usage;
			}
		}

	my $prefix = $dry_run ? 'Would remove' : 'Removed';

	foreach my $item ( $cache_list->@* ) {
		next unless $item->[0] =~ $pattern;
		my $rc = $self->cli->ebird->cache->remove( $item->[0] );
		$prefix = 'Could not remove ' if( $rc == 1 and ! $dry_run );
		$self->cli->ebird->io->output( "$prefix $item->[0]" );
		}
	}

=item * action_delete(NAMES)

Delete the named cache items.

=cut

sub action_delete ($self, @args) {
	my $cache = $self->cli->ebird->cache;

	$self->cli->ebird->io->output( <<~"HERE" );
		# Cache directory: @{[$self->cli->ebird->cache->dir]}
		# EBIRD_CACHE_DIR: @{[$ENV{EBIRD_CACHE_DIR} // '<not set>']}
		# --------------------------------------------
		HERE

	foreach my $arg (@args) {
		my $path = catfile( $self->cli->ebird->cache->dir, $arg );
		my $message = do {
			   if( ! $cache->exists($arg) ) { "$arg does not exist"            }
			elsif( ! $cache->remove($arg) ) { "$arg could not be removed ($!)" }
			else                            { "$arg removed"                   }
			};

		$self->cli->ebird->io->output( $message );
		}
	}

=item * action_help

=cut

sub action_help ($self) {
	$self->cli->ebird->io->output( "Help for " . __PACKAGE__ );
	}

=item * action_list( [PATTERN] )

List all of the cache items. If you specify a Perl pattern, list only the
items that match that pattern.

=cut

sub action_list ( $self, @args ) {
	state $format = "%s      %s";

	my $pattern = qr/./;
	if( @args ) {
		$pattern = eval { qr/$args[0]/ };
		unless( defined $pattern ) {
			$self->cli->ebird->io->error( "Invalid pattern <$args[0]>" );
			$self->cli->exit_usage;
			}
		}

	$self->info_header;

	if( 0 == $self->cli->ebird->cache->list->@* ) {
		$self->cli->ebird->io->output( "\n<no items>" );
		return;
		}

	foreach my $item ( $self->cli->ebird->cache->list->@* ) {
		next unless $item->[0] =~ $pattern;
		my $date = localtime( $item->[1] );
		$self->cli->ebird->io->output( sprintf $format, $date, $item->[0] );
		}
	}

=item * action_open

=cut

sub action_open ( $self, @args ) {
	my( $file ) = @args;

	my $path = $self->cli->ebird->cache->path( $file );
	unless( -e $path ) {
		$self->cli->ebird->logger->error( "There is no <$file> in the cache" );
		return;
		}

	if( length $ENV{EDITOR} ) {
		my $rc = system $ENV{EDITOR}, $path;
		if( $rc == -1 ) {
			$self->cli->ebird->logger->error( "Could not open file with <$ENV{EDITOR}>" );
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
			$self->cli->ebird->logger->error( "Could not open <$path> with <$command[0]>" );
			return;
			}

		return $rc
		}

	}

=item * action_show

=cut

sub action_show ( $self, @args ) {
	$self->cli->ebird->io->output(
		$self->cli->ebird->cache->load( $args[0] )
		);
	}

=item * info_header

Outputs the information header that shows the current cache location and
the value from the environment.

=cut

sub info_header ( $self, @args ) {
	$self->cli->ebird->io->output( <<~"HERE" );
		# Cache directory: @{[$self->cli->ebird->cache->dir]}
		# EBIRD_CACHE_DIR: @{[$ENV{EBIRD_CACHE_DIR} // '<not set>']}
		# --------------------------------------------
		HERE
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
