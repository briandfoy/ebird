use v5.36;
package eBird::Data::Country;
use parent qw(Hash::AsObject);

=head1 NAME

eBird::Data::Country - the representation of country information

=head1 SYNOPSIS

	my $countries = $eBird->region->countries;
	foreach my $c ( $countries->@* ) {
		printf "%2s  -->  %s\n", $c->short_code, $c->name;
		}

=head1 DESCRIPTION

These objects represent the countries that eBird understands.

=over 4

=item * name

Returns the full name of the country.

=item * short_code

An alias for C<code>.

=cut

sub short_code ($self) { $self->code }

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;
