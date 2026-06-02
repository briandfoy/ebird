use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Base;
use parent qw(Hash::AsObject);

use namespace::autoclean;
use Scalar::Util qw(blessed);

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

sub can ($self, $method) {
	return 1 if blessed($self) && exists $self->{$method};
	return 1 if blessed($self) && defined &{ join '::', blessed($self), $method};
	return 1 if defined &{ join '::', $self, $method };
	return 0;
	}

=item * ebird

Return a quiet L<eBird> object.

=cut

sub ebird {
	state $rc = do { require eBird; require eBird::IO };
	eBird->new( io => eBird::IO->new_quiet )
	}


=item * new_from_api_response

=cut

sub new_from_api_response ($class, $ref) {
	bless $ref, $class;
	}

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
