use v5.38;
use utf8;
no feature qw(module_true);

package eBird::LatLong;
use namespace::autoclean;
use Carp qw(croak);
use List::Util qw(first);
use Mojo::URL;
use Scalar::Util qw(blessed looks_like_number);

use eBird;
use eBird::IO;
use eBird::Nearby;

=encoding utf8

=head1 NAME

eBird::LatLong - handle latitude and longitude for the eBird API

=head1 SYNOPSIS

=head1 DESCRIPTION

Most of the eBird API endpoints that deal with geocoordinates want latitude
and longitude in decimal with up to two decimal places. This module handles
all of that, whether you create the object directly or from a more sophisticated
geocoordinates module.

=over 4

=item * new_from_decimal( $lat, $long [, eBird] )

Creates a new L<eBird::LatLong> object from two floating point numbers. The
latitude must be inclusively between [-90,90] and the longitude must be between
[-180,180].

=cut

sub new_from_decimal {
	my( $class, @args ) = @_;
	my $ebird = do {
		if( $args[-1] isa 'eBird' ) { pop @args }
		else { eBird->new( io => eBird::IO->new_quiet )}
		};

	my( $lat, $long ) = @args;

	unless( defined $lat and defined $long ) {
		croak "Too few arguments for new_from_decimal";
		}

	no warnings qw(numeric);
	unless( looks_like_number($lat) and looks_like_number($long) ) {
		$ebird->io->carp("Latitude ($lat) must be in [-90,90] and Longitude ($long) must be in [-180,180]");
		return;
		}
	unless( abs($lat) <= 90 and abs($long) <= 180 ) {
		$ebird->io->carp("Latitude ($lat) must be in [-90,90] and Longitude ($long) must be in [-180,180]");
		return;
		}

	bless {
		lat   => sprintf( '%.2f', $lat  ),
		long  => sprintf( '%.2f', $long ),
		ebird => $ebird,
		}, $class;
	}

=item * new_from_any( ANY )

Use any object geocoordinates object you like to construct the object as long
as it responds to the noted methods. This way, you can use any input formats
you like.

The latitude methods are one of C<lat>, C<latitude>, or C<y>.

The longitude methods are one of C<lon>, C<longitude>, C<lng>, C<long>, or C<x>.

If C<ANY> is this class or one derived from it, it returns the same object.

=cut

sub new_from_any ( $class, $any, $ebird = eBird->new( io => eBird::IO->new_quiet ) ) {
	return $any if $any isa $class;

	my($lat_method)  = grep { $any->can($_) } qw(lat latitude y);
	my($long_method) = grep { $any->can($_) } qw(lon longitude lng long x);

	my $lat  = $any->$lat_method;
	my $long = $any->$long_method;

	$class->new_from_decimal( $lat, $long, $ebird );
	}

=back

=head2 Instance methods

=over 4

=item * distance_to( OBJ )

Returns the distance to the location of C<OBJ>, using the same rules as C<new_from_any>.
Many of the eBird API location-based objects have C<lat> and C<lng> methods that
C<new_from_any> can handle.

=cut

sub distance_to ($self, $any ) {
	state $rc = require GIS::Distance;
	state $gis = GIS::Distance->new;

	my $to = (blessed $self)->new_from_any($any);
	return unless defined $to;

	1_000 * $gis->distance_metal(
		$self->lat, $self->long,
		$to->lat,   $to->long,
		);
	}

=item * ebird

Returns the internal L<eBird> object.

=cut

sub ebird ($self) { $self->{'ebird'} }

=item * elevation

=cut

sub elevation ($self) {
	state $url = Mojo::URL->new('https://api.opentopodata.org/v1/srtm90m');
	return $self->{'elevation'} if defined $self->{'elevation'};

	my $config = $self->ebird->config;
#	return unless $config->elevation_enabled;

	my $query = {
		locations => join ',', map { $self->$_() } qw(latitude longitude),
		};

	my $tx = $self->ebird->ua->get($url => form => $query);

	my $json = $tx->res->json;
	$self->{'elevation'} = eval { $json->{'results'}[0]{'elevation'} };

	return $self->{'elevation'};
	}

=item * lat

=item * latitude

Returns the decimal latitude to two decimal places.

=cut

sub latitude ($self) { $self->{'lat'} }
*lat = \&latitude;

=item * lng

=item * lon

=item * long

=item * longitude

Returns the decimal longitude to two decimal places.

=cut

sub longitude ($self) { $self->{'long'} }
*lon  = \&longitude;
*long = \&longitude;
*lng  = \&longitude;

=item * region

=cut
sub dumper { state $rc = require Data::Dumper; Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump }

sub region_info ($self) {
	eBird::Nearby->new( $self, $self->ebird )->region;
	}

=item * time_zone_offset

=cut

sub time_zone_offset ($self) {
	state $url = Mojo::URL->new('http://api.geonames.org/timezoneJSON');
	my $query = {
		lat      => $self->latitude,
		lon      => $self->longitude,
		username =>
		};


	}

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/ebird

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT

Copyright 2023-2026, brian d foy C<< <briandfoy@pobox.com> >>

=cut

__PACKAGE__;
