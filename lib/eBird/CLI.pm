use v5.20;
package eBird::CLI;
use experimental qw(signatures);

use eBird;

use Mojo::Log;
use Mojo::File;

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class Methods

=over 4

=item * new( KEY => VALUE [, KEY => VALUE ...] )

Create the object that coordinates the command line interface.

Keys

	- api       - the object that handles the API bits (eBird::API)
	- logger    - a Mojo::Log compatible logging object
	- log_level -
	- name      - the program name to declare
	- version   - the version to declare

=cut

sub new ($class, %arguments) {
	state %defaults = qw(
		log_level warn
		name ebird
		);
	state %required = map { $_, 1 } qw(api_key);

	my %options = ( %defaults, %arguments );

	my $self = bless {}, $class;
	$self->{logger} = Mojo::Log->new( level => $options{log_level} );

	my @missing = grep { ! exists $options{$_} } keys %required;
	if( @missing ) {
		$self->logger->error( 'Missing keys <@missing>' );
		return;
		}

	$self->{options} = \%options;
	$self->{name} = $options{name};
	$self->{version} = $options{version};
	$self->{api} = eBird->new(
		api_key => $options{api_key},
		logger  => $self->{logger},
		);


	$self->load_commands;

	return $self;
	}

sub DESTROY ( $self ) {
	delete $self->{api};
	}

=back

=head2 Instance methods

=over 4

=item * api

Returns the object that handles the API details

=cut

sub api ( $self ) { $self->{api} }

=item * logger

Returns the logger object, which should have the same interface as
L<Mojo::Log>.

=cut

sub logger ( $self ) { $self->{logger} }

=item * name

Returns the name of the program, which is "ebird" by default.

=cut

sub name ($self ) { $self->{name} }

=item * load_commands

Find the modules that implement the commands and load them through
C<load_file>.

=cut

sub load_commands ($self) {
	state $base_namespace = 'eBird::Command';
	state @namespace_dirs = split /::/, $base_namespace;


	foreach my $dir ( @INC ) {
		$self->logger->trace( "looking in dir <$dir> for command module" );
		my $sub_dir = Mojo::File->new($dir)->child( @namespace_dirs );
		next unless -d $sub_dir;
		opendir my $dh, $sub_dir;
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
	$self->logger->trace( "Trying to load module <$file>" );
	my $class;
	eval "\$class = require q($file)";
	if( $@ ) {
		$self->logger->error( "Tried to load file <$file> but failed: $@" );
		return;
		}

	$self->logger->trace( "Module name is <$class>" );
	my $rc = $self->register( $class );
	return 1;
	}

=item * output

Send output to the standard output filehandle.

=cut

sub output ( $self, @messages ) {
	print STDOUT join "\n", @messages;
	}

=item * error

Send output to the error filehandle.

=cut

sub error ( $self, @messages ) {
	print STDERR join "\n", @messages;
	}

=item * output_data

At the moment this does nothing. Maybe we'll remove it.

=cut

sub output_data ( $self, $data, @args ) {
	return;
	}


=item * handlers

Returns the names of all the handlers as a list.

=cut

sub handlers ( $self ) {
	values $self->{commands}->%*;
	}

=item * register( CLASS )

Register a class that contains commands.

=cut

sub register ( $self, $class ) {
	unless( $class->can('register') ) {
		$self->logger->error( "Tried to register <$class> but it does not have a register method" );
		return;
		}

	my $handler = $class->register( $self );
	my $name = $handler->name;
	if( exists $self->{commands}{$name} ) {
		$self->logger->error( "A command with name <$name> already exists." );
		return;
		}

	$self->{commands}{lc $name} = $handler;

	}

=item * run( COMMAND, @ARGS )

The main entry point to the program. It runs the command named C<COMMAND>
and passes the C<ARGS> array.

=cut

sub run ( $self, $command, @args ) {
	$self->{commands}{lc $command}->run( @args );
	}

=item * version

Returns the version of the command.

=cut

sub version ( $self ) {
	$self->{version};
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
