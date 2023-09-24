use v5.38;
no feature qw(module_true);

package eBird::Checklist;
use parent qw(Hash::AsObject);

use experimental qw(builtin);

use builtin qw(weaken reftype);

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

sub birder ( $self ) { $self->userDisplayName }

sub id ( $self ) { $self->subId }

sub observations ( $self ) { $self->obs }

sub region ( $self ) { $self->subnational1Code }

sub time_ended ( $self ) { $self->creationDt }

sub time_started ( $self ) { $self->obsDt }


__PACKAGE__;

__END__
