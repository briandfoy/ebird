use v5.38;
use utf8;

use File::Temp;

sub clear_env () {
	delete $ENV{$_} for grep { /^EBIRD_/ } keys %ENV;
	}

sub help_shows_command ($cli, $command) {
	subtest 'help shows command' => sub {
		isa_ok $cli, 'eBird::CLI';
		can_ok $cli, qw(run);

		my $rc = eval { $cli->run('help') } && diag $@;
		is $rc, 0, 'successful exit';
		like $cli->ebird->io->output_history, qr/^ \h+ \Q$command\E \h+ - \h+ /mx,
			"Found <$command> in help listing";
		}
	}

sub make_ebird () {
	state $class = 'eBird';
	state $ebird;
	return $ebird if defined $ebird;

	my $io     = make_io();
	my $logger = make_logger();
	my $config = make_config();

	my $cache  = make_cache($io, $logger);

	subtest 'make ebird' => sub {
		use_ok $class;
		$ebird = $class->new(
			cache  => $cache,
			config => $config,
			io     => $io,
			logger => $logger,
			);

		isa_ok $ebird, 'eBird';
		};

	return $ebird;
	}

sub make_cli () {
	state $class = 'TestCLI';
	state $cli;
	return $cli if defined $cli;

	subtest 'make CLI' => sub {
		use_ok $class;
		$cli = $class->new( ebird => make_ebird() );
		isa_ok $cli, $class;
		isa_ok $cli, 'eBird::CLI';
		can_ok $cli, qw(run);
		};

	return $cli;
	}

sub make_cache ($io, $logger) {
	state $class = 'eBird::Cache';
	state $cache;
	return $cache if defined $cache;

	subtest 'make cache' => sub {
		use_ok $class;
		my $dir = File::Temp::tempdir;
		$cache = $class->new(
			dir    => $dir,
			io     => $io,
			logger => $logger,
			)
		};

	return $cache;
	}

sub make_config () {
	state $class = 'eBird::Config';
	state $config;
	return $config if defined $config;

	subtest 'make config' => sub {
		use_ok $class;
		$config = $class->new;
		isa_ok $config, $class;
		};

	return $config;
	}

sub make_config_file () {
	}

sub make_io () {
	state $class = 'eBird::IO';
	state $io;
	return $io if defined $io;

	subtest 'make io' => sub {
		use_ok $class;

		$io = $class->new_quiet;
		isa_ok $io, $class;
		ok $io->is_quiet, "quiet is on";
		};

	return $io;
	}

sub make_logger () {
	state $class = 'Mojo::Log';
	state $logger;
	return $logger if defined $logger;

	my( $fh, $filename ) = File::Temp::tempfile;

	subtest 'make logger' => sub {
		use_ok $class;

		$logger = $class->new( path => $filename, level => $ENV{'EBIRD_LOG_LEVEL'} // 'warn' );
		isa_ok $logger, $class;
		};

	return $logger;
	}

1;
