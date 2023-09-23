use v5.38;
no feature qw(module_true);

package eBird::Command::help;
use parent qw(eBird::Command);

sub run ( $self ) {
	$self->cli->output( sprintf "%s %s\n\n", map {$self->cli->$_()} qw(name version) );

	$self->cli->output( "Commands\n\n" );

	foreach my $handler ( sort { $a->name cmp $b->name } $self->cli->handlers ) {


		my $string = join "\n",
			$handler->name,
			$handler->description, "\n";

		$string =~ s/^(?!\R)/\t/gm;

		$self->cli->output( $string );
		}
	}


__PACKAGE__;
