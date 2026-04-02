use v5.20;
use utf8;

package eBird::CLI;
use experimental qw(signatures);

use eBird;

use namespace::autoclean;
use Carp qw(shortmess);

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

eBird::CLI - the general framework for the Perl C<ebird> command

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class Methods

=over 4

=item * new( KEY => VALUE [, KEY => VALUE ...] )

Create the object that coordinates the command line interface.

Keys:

	- ebird     - the object that handles the API bits (eBird)
	- name      - the program name to declare
	- version   - the version to declare

=cut

sub new ($class, %arguments) {
	state %defaults = (
		name    => 'ebird',
		version => $VERSION,
		ebird   => eBird->new,
		);

	my %options = ( %defaults, %arguments );
	my $self = bless \%options, $class;

	$self->load_commands;
	return $self;
	}

sub DESTROY ($self) {
	delete $self->{'ebird'};
	}

=back

=head2 Instance methods

=over 4

=item * cache

=cut

sub cache ($self) {
	$self->ebird->io->error( shortmess "deprecated use of <cache> instead of <ebird->cache>" );
	$self->ebird->cache
	}

=item * io

Returns the object that handles input and output. This is typically an
L<eBird::IO> object.

=cut

sub io ($self) {
	$self->ebird->io->error( shortmess "deprecated use of <io> instead of <ebird->io>" );
	$self->ebird->io
	}

=item * ebird

Returns the object that handles the API details. This is typically an
L<eBird> object.

=cut

sub ebird ($self) { $self->{'ebird'} }

=item * exit(N)

Exit with value C<N>.

This exists so you can override this to test the program without actually
exiting.

=cut

sub exit ($self, $n) { CORE::exit($n) }

=item * exit_error

Exit with value C<1>.

=cut

sub exit_error ($self) { $self->exit(1) }

=item * exit_usage

Exit with value C<2>.

=cut

sub exit_usage ($self) { $self->exit(2) }

=item * logger

Returns the logger object, which should have the same interface as
L<Mojo::Log>.

=cut

sub logger ($self) {
	$self->ebird->io->error( shortmess "deprecated use of <logger> instead of <ebird->logger>" );
	$self->ebird->logger;
	}

=item * name

Returns the name of the program, which is "ebird" by default.

=cut

sub name ($self) { $self->{'name'} }

=item * load_commands

Find the modules that implement the commands and load them through
C<load_file>.

=cut

sub load_commands ($self) {
	state $base_namespace = 'eBird::Command';
	state @namespace_dirs = split /::/, $base_namespace;

	foreach my $dir ( @INC ) {
		$self->ebird->logger->trace( "looking in dir <$dir> for command module" );
		my $sub_dir = Mojo::File->new($dir)->child( @namespace_dirs );
		next unless -d $sub_dir;
		opendir my($dh), $sub_dir;
		my @files =
			map  { Mojo::File->new( @namespace_dirs )->child($_) }
			grep { /\b[A-Z_]\w*\.pm\z/ai }
			readdir($dh);

		foreach my $file ( @files ) {
			$self->load_file($file);
			}
		}
	}

=item * load_file

Load a module and register its commands.

=cut

sub load_file ($self, $file) {
	state $loaded = {};
	return $loaded->{$file} if exists $loaded->{$file};

	$loaded->{$file} = 0;
	$self->ebird->logger->trace( "Trying to load module <$file>" );
	my $class;
	eval "\$class = require q($file)";

	if( $@ ) {
		$self->ebird->logger->error( "Tried to load file <$file> but failed: $@" );
		return;
		}

	$loaded->{$file} = 1;

	$self->ebird->logger->trace( "Module name is <$class>" );
	my $rc = $self->register( $class );
	return 1;
	}

=item * handlers

Returns the names of all the handlers as a list.

=cut

sub handlers ($self) {
	values $self->{'commands'}->%*;
	}

=item * register( CLASS )

Register a class that contains commands.

=cut

$|++;
sub register ($self, $class) {
	unless( $class->can('register') ) {
		$self->ebird->logger->error( "Tried to register <$class> but it does not have a register method" );
		return;
		}

	my $handler = $class->register( $self );
	my $name = $handler->name;
	if( exists $self->{'commands'}{$name} ) {
		$self->ebird->logger->error( "A command with name <$name> already exists." );
		return;
		}

	$self->{'commands'}{lc $name} = $handler;
	}

=item * run( COMMAND, @ARGS )

The main entry point to the program. It runs the command named C<COMMAND>
and passes the C<ARGS> array.

=cut

sub run ($self, $command, @args) {
	my $rc = $self->{'commands'}{lc $command}->run( @args );
	defined $rc ? $self->exit($rc) : $self->exit_error;
	}

=item * version

Returns the version of the command.

=cut

sub version ($self) {
	$self->{'version'};
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
