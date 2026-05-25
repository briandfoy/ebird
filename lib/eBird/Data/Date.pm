use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Date;
use parent qw(eBird::Data::Base);

use eBird;

=encoding utf8

=head1 NAME

eBird::Data::Date - the representation of an eBird date

=head1 SYNOPSIS

=head1 DESCRIPTION

These objects represent the information eBird tracks about a region.

=over 4

=item * new

=cut

sub new ($class, $date) {
	my $hash = $class->parse($date);

	bless $hash, $class;
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
		date   => $day,
		hour   => $hour,
		minute => $minute,
		};
	}

=back

=head2 Tests

=over 4

=item * is_this_week

=item * is_this_month

=item * is_this_year

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
