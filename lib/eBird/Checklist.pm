use v5.38;
no feature qw(module_true);

package eBird::Checklist;
use parent qw(Hash::AsObject);

use experimental qw(builtin);

use builtin qw(weaken reftype);

=encoding utf8

=head1 NAME

eBird::Checklist -

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new

=cut

package eBird::Observation {
	use parent qw(Hash::AsObject);

	sub species_code ( $self ) { $self->speciesCode }
	sub count ( $self )        { $self->howManyStr }
	}

sub new ( $class, $hash ) {
	my $self = bless $hash, $class;

	my $obs = map { eBird::Observation->new($_) } $self->obs->@*;

	return $self;
	}

=back

=head2 Instance methods

=over 4

=item * birder

=cut

sub birder ( $self ) { $self->userDisplayName }

=item * id

=cut

sub id ( $self ) { $self->subId }

=item * observations

=cut

sub observations ( $self ) { $self->obs }

=item * region

=cut

sub region ( $self ) { $self->subnational1Code }

=item * time_ended

=cut

sub time_ended ( $self ) { $self->creationDt }

=item * time_started

=cut

sub time_started ( $self ) { $self->obsDt }


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
