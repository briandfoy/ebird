use v5.38;
use utf8;

package eBird::Cache;

use namespace::autoclean;
use Carp qw(carp);
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);
use Mojo::Log;
use Mojo::Util qw(decode encode);

=encoding utf8

=head1 NAME

eBird::Cache - handle the cache

=head1 SYNOPSIS

Most of this is handled for you in the L<eBird> module when you construct a
new object.

	my $cache = eBird::Cache->new(
		config => eBird::Config->new,
		io     => eBird::IO->new,
	    logger => Mojo::Log->new,
		);


=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new

	- cache_dir
	- logger

=cut

sub new ( $class, %args ) {
	state %defaults = (
		config => eBird::Config->new,
		io     => eBird::IO->new,
		logger => Mojo::Log->new,
		);

	my %hash;

	$hash{'dir'} = Mojo::File->new(
		$args{'dir'} // catfile( $ENV{HOME}, '.ebird-perl', 'cache' )
		);
	$hash{'logger'}  //= Mojo::Log->new( level => 'warn' );

	my $self = bless \%hash, $class;
	}

=back

=head2 Instance methods

=over 4

=item * dir

Returns the path to the cache directory. By default, this is
C<~/.ebird-perl/cache>

=cut

sub _make_dir ( $self ) {
	if( -e $self->dir and ! -d $self->dir ) {
		$self->io->error( shortmess("Cache dir <%s> exists but is not a directory") );
		return;
		}
	elsif( -e $self->dir ) {
		return;
		}
	else {
		make_path $self->dir;
		}
	}

sub dir ( $self ) { $self->{'dir'} }

=item * exists(NAME)

Returns true if there is a cache item with C<NAME>, and false otherwise.

=cut

sub exists ($self, $name) {
	-e $self->dir->child($name);
	}

=item * list()

Return a list of the items in the cache. Each item is a tuple of
of the file basename and its inode creation time.

=cut

sub list ( $self ) {
	$self->dir->list
		->map( sub { [ $_->basename, $_->stat->ctime ] } )
		->to_array
	}

=item * load( KEY )

Load a cache item named KEY and return the raw octets.

=cut

sub load ( $self, $key ) {
	$self->logger->debug( "Looking for $key in cache" );
	my $file = $self->path($key);
	return unless -e $file;

	$self->logger->debug( "Found $key in cache" );

	$file->slurp;
	}

=item * load_decode( KEY [, ENCODING] )

Loads a cache item and decoded it as C<ENCODING>. If you don't specify an
encoding, this uses C<UTF-8>.

=cut

sub load_decode ( $self, $key, $encoding = 'UTF-8' ) {
	my $decoded = eval{
		decode( $encoding, $self->load($key) )
		};
	return $decoded unless $@;
	$self->logger->error( "Could not decode data for <$key> with C<$encoding>: $@" );
	return;
	}

=item * logger()

=cut

sub logger ( $self ) { $self->{logger} }

=item * path( KEY )

Returns a L<Mojo::File> object for the file represented by KEY.

=cut

sub path ( $self, $key ) {
	$self->dir->child($key);
	}

=item * remove( KEY )

Remove the file represented by KEY.

=cut

sub remove ( $self, @keys ) {
	$self->logger->debug( "remove: @keys" );
	$self->path($_)->remove for @keys;
	}

=item * save( KEY, STRING )

Save C<STRING> as raw octets.

=cut

sub save ( $self, $key, $string ) {
	$self->logger->debug( "save: Saving data to $key. Bytes " . length $string );
	$self->_make_dir;
	$self->path($key)->spurt( $string );
	}

=item * save_encode( KEY, STRING [, ENCODING] )

Encode C<STRING> as C<ENCODING> (or UTF-8 by default) and save it.

=cut

sub save_encode ( $self, $key, $string, $encoding = 'UTF-8' ) {
	$self->save( $key, encode $encoding, $string );
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
