#!perl
use v5.38;
use lib qw(lib);
use eBird::IO;

DEFAULT: {
	my $io = eBird::IO->new;

	# these all output
	$io->output( "Default on STDOUT"        );
	$io->error(  "Default on STDERR"        );
	$io->carp(   "Default shortmess STDERR" );

	$io->turn_on_quiet;
	# now we don't output
	$io->output( "QUIET on STDOUT (should not see)"        );
	$io->error(  "QUIET on STDERR (should not see)"        );
	$io->carp(   "QUIET shortmess STDERR (should not see)" );

	$io->turn_off_quiet;
	# we output again
	$io->output( "QUIET OFF on STDOUT (should not see)"        );
	$io->error(  "QUIET OFF on STDERR (should not see)"        );
	$io->carp(   "QUIET OFF shortmess STDERR (should not see)" );
	}

QUIET: {
	my $io = eBird::IO->new_quiet;
	# none of these will output because the filehandle do nothing
	say STDERR "There should be no output---------";
	$io->output( "Default on STDOUT"        );
	$io->error(  "Default on STDERR"        );
	$io->carp(   "Default shortmess STDERR" );

	$io->turn_on_quiet;
	$io->output( "QUIET on STDOUT (should not see)"        );
	$io->error(  "QUIET on STDERR (should not see)"        );
	$io->carp(   "QUIET shortmess STDERR (should not see)" );

	$io->turn_off_quiet;
	$io->output( "QUIET OFF on STDOUT (should not see)"        );
	$io->error(  "QUIET OFF on STDERR (should not see)"        );
	$io->carp(   "QUIET OFF shortmess STDERR (should not see)" );
	say STDERR "There can be output again---------";
	}

BEGIN {
	package eBird::IO::Rot13;
	sub new { bless {}, $_[0] }
	sub print ($self, $message) {
		$message =~ tr/A-Za-z/N-ZA-Mn-za-m/;
		print STDOUT $message;
		}
	}
FANCY: {
	my $io = eBird::IO->new(
		output_fh => eBird::IO::Rot13->new,
		);

	# Only the output handle is affected
	say STDERR "There should ROT13 on STDOUT---------";
	$io->output( "Default on STDOUT"        );
	$io->error(  "Default on STDERR"        );
	$io->carp(   "Default shortmess STDERR" );

	$io->turn_on_quiet;
	$io->output( "QUIET on STDOUT (should not see)"        );
	$io->error(  "QUIET on STDERR (should not see)"        );
	$io->carp(   "QUIET shortmess STDERR (should not see)" );

	$io->turn_off_quiet;
	$io->output( "QUIET OFF on STDOUT (should not see)"        );
	$io->error(  "QUIET OFF on STDERR (should not see)"        );
	$io->carp(   "QUIET OFF shortmess STDERR (should not see)" );
	say STDERR "Stop ROT13---------";
	}
