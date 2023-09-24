use v5.20;
package eBird::CLI;
use experimental qw(signatures);

use eBird;

use Mojo::Log;
use Mojo::File;

our $VERSION = '0.001_01';


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

sub api ( $self ) { $self->{api} }

sub logger ( $self ) { $self->{logger} }

sub name ($self ) { $self->{name} }

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

sub output ( $self, @messages ) {
	print STDOUT join "\n", @messages;
	}

sub error ( $self, @messages ) {
	print STDERR join "\n", @messages;
	}

sub output_data ( $self, $data, @args ) {

	}


sub handlers ( $self ) {
	values $self->{commands}->%*;
	}

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

sub run ( $self, $name, @args ) {
	$self->{commands}{lc $name}->run( @args );
	}

sub version ( $self ) {
	$self->{version};
	}
