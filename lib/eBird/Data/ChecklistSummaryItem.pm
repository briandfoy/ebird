use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Country;
use parent qw(eBird::Data::Base);

=encoding utf8

=head1 NAME

eBird::Data::ChecklistSummaryItem - the representation of a checklist scraped from the website

=head1 SYNOPSIS

	my $countries = $eBird->region->countries;
	foreach my $c ( $countries->@* ) {
		printf "%2s  -->  %s\n", $c->short_code, $c->name;
		}

=head1 DESCRIPTION


=over 4

=item * checklist

=item * code

Returns the checklist identifier, such as C<S123456780>.

=cut

sub code ($self) { $self->checklist }

=item * date

The day of the month

=item * datetime

=item * epoch

=item * hour

=item * location

The name of the location

=item * minute

=item * month

=item * offset

The timezone offset

=item * region

=item * second

=item * sequence

The position in the list of all checklists for a user. This is not stable since
checklists may be added or deleted.

=item * subnational1

=item * subnational2

=item * title

=item * year

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

__END__
=begin comment

 {
    "checklist" => "S119442062",
    "date" => 11,
    "datetime" => bless( do{\(my $o = "l\352\260\332\16\0\0\0\0\0\0\0p\376\377\377")}, 'Time::Moment' ),
    "day" => "Sunday",
    "epoch" => 1662910380,
    "hour" => 8,
    "location" => "Creamer Ln, Fairbanks US-AK (64.8624,-147.7374)",
    "minute" => 53,
    "month" => 9,
    "offset" => "-0400",
    "region" => "United States",
    "second" => 0,
    "sequence" => 92,
    "subnational1" => "Alaska",
    "subnational2" => "Fairbanks North Star Borough",
    "title" => "Checklist S119442062 - Sunday, September 11, 2022 8:53 AM",
    "year" => 2022
  },

=end comment

=cut
