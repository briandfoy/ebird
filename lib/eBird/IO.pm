package eBird::IO;
use v5.38;

=encoding utf8

=head1 NAME

eBird::IO - generalize the output

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new()

=cut

sub new ( $class, %args ) {
	binmode STDOUT, ':encoding(UTF-8)';
	binmode STDERR, ':encoding(UTF-8)';

	my %hash = (
		error  => \*STDERR,
		output => \*STDOUT,
		);

	my $self = bless \%hash, $class;
	}

=back

=head2 Instance methods

=over 4

=item * error( ARRAY_OF_STRINGS )

Join ARRAY_OF_STRINGS with a newline and send to the error filehandle.

=cut

sub error ( $self, @strings ) {
	$self->_send_it( $self->_error_fh, join "\n", @strings );
	}

=item * output( ARRAY_OF_STRINGS )

Join ARRAY_OF_STRINGS with a newline and send to the standard filehandle.

=cut

sub output ( $self, @strings ) {
	$self->_send_it( $self->_output_fh, join "\n", @strings );
	}

sub _error_fh ( $self ) { $self->{error} }

sub _output_fh ( $self ) { $self->{output} }

sub _send_it ( $self, $fh, $string ) {
	print {$fh} $string
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
