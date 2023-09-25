use v5.38;
no feature qw(module_true);

package eBird::Util;
use B;
use Exporter qw(import);

our @EXPORT_OK;
our %EXPORT_TAGS;

sub MODIFY_CODE_ATTRIBUTES ( $package, $code_ref, @attributes ) {
	my( $sub_name ) = B::svref_2object( $code_ref )->GV->NAME;

	my @bad_attributes = ();
	foreach my $attribute ( @attributes ) {
		my( $attribute_name ) = map { uc() } $attribute =~ m/\A(\w+)/;
		no strict 'refs';
		if( exists &{"ATTRIBUTE_$attribute_name"} ) {
			push @bad_attributes, $attribute if &{"ATTRIBUTE_$attribute_name"}( $package, $code_ref, $attribute )
			}
		else { push @bad_attributes, $attribute }
		}

	@bad_attributes;
	}

sub ATTRIBUTE_EXPORT ( $package, $code_ref, $attribute ) {
	my( $sub_name ) = B::svref_2object( $code_ref )->GV->NAME;
	$sub_name =~ s/.*:://;

	push @EXPORT_OK, $sub_name;
	push $EXPORT_TAGS{'all'}->@*, $sub_name;

	return;
	}

=encoding utf8

=head1 NAME

eBird::Util - basic utilities for getting stuff done

=head1 SYNOPSIS

	use eBird::Util qw(:all);

=head1 DESCRIPTION

=head2 Functions

All of these funcitons are exportable on request, or with the C<:all>
export tag.

=over 4

=item * looks_like_checklist_id( STRING )

Returns true if C<STRING> has the format of a checklist ID. These
start with an C<S> and is followed by digits. This is the number
you see in the URL on the website, such as L<https://ebird.org/merlin/checklist/S137137137>.

There are other IDs given to checklists, but those are not useful for
the eBird API.

Passing this test does not mean that C<STRING> is valid.

=cut

# There is a checklistId in the response, but that is not a checklist ID
sub looks_like_checklist_id :Export ( $checklist ) {
	uc($checklist) =~ m/
		\A
		S \d+
		\z
		/xa;
	}

=item * looks_like_region( REGION )

Returns true if C<REGION> has the same format as an eBird region. That's
the two letter country code, subnational code, and subnational2 code (for
some regions) separated by hyphens, such as C<US-NY-109>.

Passing this test does not mean that C<REGION> is valid.

=cut

sub looks_like_region :Export ( $region ) {
#	return 1 if $region eq 'world';

	uc($region) =~ m/
		\A
		[A-Z]{2}
		(
			- [A-Z]+
			( - \d+ )?
		)?
		\z
		/xna;
	}

=item * matches_hotspot_id( ID )

Returns true if C<ID> has the same format as an eBird hotspot. These
start with an C<L> and is followed by digits. This is the number
you see in the URL on the website, such as L<https://ebird.org/hotspot/L164554>.

Passing this test does not mean that C<ID> is valid.

=cut

sub matches_hotspot_id :Export ( $id ) {
	$id =~ m/\AL\d+\z/a
	}

=item * latitude_in_range( LATITUDE )

Returns true if the value of LATITUDE is between -90. and 90 inclusively.

=cut

sub latitude_in_range :Export ($latitude) {
	-90 <= $latitude <= 90
	}

=item * longitude_in_range( LONGITUDE )

Returns true if the value of LONGITUDE is between -180. and 180 inclusively.

=cut

sub longitude_in_range :Export ($longitude) {
	-180 <= $longitude <= 180

	}

=item * month_in_range( MONTH_NUMBER )

Returns true if the value of MONTH_NUMBER is a whole number and is
between 1 and 12 inclusively.

=cut

sub month_in_range :Export ($month) {
	1 <= $month <= 12 and int($month) == $month;
	}

=item * year_in_range( YEAR_NUMBER )

Returns true if the year is a whole number and is between 1800 and the
current year, inclusively. The year 1800 is the earliest available in
the eBird API.

=cut

sub year_in_range :Export ($year) {
	state $this_year = Time::Moment->new->year;
	1800 <= $year <= $this_year and int($year) == $year;
	}

=item * day_in_range( YEAR, MONTH, DAY )

Returns true if DAY is a valid date for MONTH in YEAR.

=cut

sub day_in_range :Export ($year, $month, $day) {
	my $tm = Time::Moment->new(
		year => $year,
		month => $month,
		day  => 1,
		);

	my $max = $tm->at_last_day_of_month->day_of_month;

	1 <= $day <= $max and int($day) == $day;
	}

=item * normalize_date( DATE_STRING )

Normalizes DATE_STRING to a hash with the keys C<year>, C<month>, and C<day>.

So far, it handles these formats:

	YYYYMMDD
	YYYY-MM-DD
	YYYY/MM/DD

=cut

sub normalize_date :Export ($date) {
	state $rc = require Time::Moment;
	state %day_names =
	my $date_pattern = m<
		\A
		(?|
			(?: (\d{4}) (\d{2}) (\d{2}) )
			|
			(?: (\d{4})-(\d{2})-(\d{2})  )
			|
			(?: (\d{4})/(\d{2})/(\d{2})  )
		)
		\z
		>a;

	my $tm = Time::Moment->new;

	my( $year, $month, $day );
	if( $date =~ $date_pattern  ) {
		( $year, $month, $day ) = ( $1, $2, $3 );
		}
	elsif( $date eq 'today' ) {
		my $now = $tm->now;
		( $year, $month, $day ) = map { $tm->$_() } qw(year month day_of_month);
		}
	elsif( $date eq 'yesterday' ) {
		my $yesterday = $tm->now->minus_days(1);
		( $year, $month, $day ) = map { $tm->$_() } qw(year month day_of_month);
		}
	elsif( exists $day_names{$date} ) {

		}

	{ year => $year, month => $month, day => $day }
	}

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
