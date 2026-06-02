use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Date;
use parent qw(eBird::Data::Base);

use Time::Moment;

use eBird;
use eBird::LatLong;

=encoding utf8

=head1 NAME

eBird::Data::Date - the representation of an eBird date

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the information eBird tracks about a region.

=over 4

=item * new

=cut

sub new ($class, $date, $latlong = undef ) {
	my $hash = $class->parse($date);

	$hash->{'time_moment'} = Time::Moment->new( $hash->%{qw(year month day hour minute)} );

	my $self = bless $hash, $class;

	$self->add_timezone($latlong) if $latlong;

	return $self;
	}

=item * parse

Parse a date as used in eBird and return its components as a hash.

=cut

sub parse ($class, $date) {
	my( $year, $month, $day, $hour, $minute ) =
		$date =~ m/\A(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\z/;
	return unless $year;

	return {
		year   => $year,
		month  => $month,
		day    => $day,
		hour   => $hour,
		minute => $minute,
		};
	}

sub _now_at_midnight ($self) { Time::Moment->now->at_midnight }

=back

=head2 Instance methods

=over 4

=item * add_timezone( LATLONG )

=cut

my %IANA_TO_ZONE;

sub add_timezone ($self, $latlong) {
	state $rc = require Geo::Location::TimeZoneFinder;
	state $rc2 = require DateTime::TimeZone;
	state $finder = do {
		my $file_base = $self->ebird->cache->dir->dirname->child('timezones-1970')->child('combined-shapefile-1970');

		Geo::Location::TimeZoneFinder->new( file_base => $file_base );
		};

	$self->{'latlong'} = $latlong;

	my @iana_names = $finder->time_zones_at(
		map { ( $_, $latlong->$_ ) } qw(latitude longitude)
		);
	$self->{'iana_timezone_name'} = $iana_names[0];

	my $zone = $IANA_TO_ZONE{ $self->{'iana_timezone_name'} } //= DateTime::TimeZone->new(name => $self->{'iana_timezone_name'});

	$self->{'time_moment'} = $self->{'time_moment'}->with_offset_same_instant(
		$zone->offset_for_datetime($self->{'time_moment'}) / 60
		);

	return $self;
	}

=item * as_time_moment

Return the object as a L<Time::Moment> object. This will lose some of the
extra information.

=cut

sub as_time_moment ($self) { $self->{'time_moment'} }

=item * days_ago

=cut

sub days_ago ($self) {
	Time::Moment->now->delta_days( $self->as_time_moment );
	}

=item * iana_timezone_name

=cut

sub iana_timezone_name ($self) { $self->{'iana_timezone_name'} }

=item * tz_offset

=cut

sub tz_offset ($self) { $self->{'time_moment'}->offset }

=back

=head2 Tests

=over 4

=item * is_this_week

=item * is_this_month

=item * is_this_year

=cut

sub is_this_week ($self) {

	}

sub is_this_year ($self) {

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
