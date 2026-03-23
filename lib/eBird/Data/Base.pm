use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Base;
use parent qw(Hash::AsObject);

=encoding utf8

=head1 NAME

eBird::Data::Base - the common stuff for the data classes

=head1 SYNOPSIS

	package eBird::Data::Something;
	use parent qw(eBird::Data::Base);

=head1 DESCRIPTION


=over 4

=item * can

Returns true if the object can respond to this method. With objects based
on L<Hash::AsObject>, C<can> is broken since it could also be a key in
the hash. In our case, that will not be true so we override it.

=cut

sub can ($self, $method) { exists $self->{$method} }

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
