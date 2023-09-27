package eBird::Cache;
use v5.38;

use File::Spec::Functions qw(catfile);
use Mojo::Util qw(decode encode);

=encoding utf8

=head1 NAME

eBird::Cache - handle the cache

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new

	- cache_dir
	- logger

=cut

sub new ( $class, %args ) {
	my %hash;

	$hash{cache_dir} = Mojo::File->new(
		$args{cache_dir} // catfile( $ENV{HOME}, '.ebird-perl', 'cache' )
		);
	$hash{logger}    = $args{logger} // Mojo::Log->new;

	my $self = bless \%hash, $class;
	}

=back

=head2 Instance methods

=over 4

=item * dir

Returns the path to the cache directory. By default, this is
C<~/.ebird-perl/cache>

=cut

sub dir ( $self ) { $self->{cache_dir} }

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

Load the file named KEY and return the UTF-8 octets.

=cut

sub load ( $self, $key ) {
	$self->logger->debug( "Looking for $key in cache" );
	my $file = $self->path($key);
	return unless -e $file;

	$self->logger->debug( "Found $key in cache" );

	$file->slurp;
	}

=item * logger()

=cut

sub logger ( $self ) { $self->{logger} }

=item * path( KEY )

Returns a L<Mojo::File> object for the file represented by KEY.

=cut

sub path ( $self, $key ) {
	$self->dir->child($key)
	}

=item * remove( KEY )

Remove the file represented by KEY.

=cut

sub remove ( $self, @keys ) {
	$self->logger->debug( "remove: @keys" );
	$self->path($_)->remove for @keys;
	}

=item * save( KEY, DATA )

Save the UTF-8 octets of DATA to the the file represented by KEY.

=cut

sub save ( $self, $key, $data ) {
	$self->logger->debug( "save: Saving data to $key. Bytes " . length $data );
	$self->path($key)->spurt( $data );
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
