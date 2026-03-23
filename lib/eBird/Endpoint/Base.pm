use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Base;

use namespace::autoclean;
use eBird::Util qw(last_namespace_portion);
use Scalar::Util qw(weaken);

=encoding utf8

=head1 NAME

eBird::Endpoint::Base - basics for the endpoint classes

=head1 SYNOPSIS

	package eBird::Endpoint::SomeEndpoint;
	use parent qw(eBird::Endpoint::Base);

=head1 DESCRIPTION

=head1 Class methods

=over 4

=item * new(HASH)

This is the basic constructor for all classes under C<eBird::Endpoint>.

	eBird::Endpoint::SomeEndpoint->new( ebird => $ebird );

You typically don't need to do this since C<eBird::load_module()> will handle
this for you.

=cut

sub new ($class, %args) {
	weaken( $args{'ebird'} );
	bless { ebird => $args{'ebird'} }, $class;
	}

=item * name

Returns the name which L<eBird> can use in C<add_endpoint>. By default, this
is the lowercased version of the last portion of the namespace. For example,
C<eBird::Endpoint::Geo> would turn into C<geo>.

=cut

sub name ($self) {
	last_namespace_portion($self);
	}

=back

=head1 Instance methods

=over 4

=item ebird

Returns the weakened L<eBird> instance.

=cut

sub ebird ($self) { $self->{'ebird'} }

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
