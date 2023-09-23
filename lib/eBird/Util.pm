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

# There is a checklistId in the response, but that is not a checklist ID
sub looks_like_checklist_id :Export ( $checklist ) {
	uc($checklist) =~ m/
		\A
		S \d+
		\z
		/xa;
	}

sub looks_like_region :Export ( $region ) {
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

sub matches_hotspot_id :Export ( $id ) {
	$id =~ m/\AL\d+\z/a
	}

sub latitude_in_range :Export ($latitude) {
	-90 <= $latitude <= 90
	}

sub longitude_in_range :Export ($longitude) {
	-180 <= $longitude <= 180

	}

sub month_in_range :Export ($month) {
	1 <= $month <= 12 and int($month) == $month;
	}

sub year_in_range :Export ($year) {
	state $this_year = Time::Moment->new->year;
	1800 <= $year <= $this_year and int($year) == $year;
	}

sub day_in_range :Export ($year, $month, $day) {
	my $tm = Time::Moment->new(
		year => $year,
		month => $month,
		day  => 1,
		);

	my $max = $tm->at_last_day_of_month->day_of_month;

	1 <= $day <= $max and int($day) == $day;
	}

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

__PACKAGE__;

__END__
 bless( {
    "all_time_species" => 44,
    "country" => "US",
    "last_observation" => "2023-08-11 11:17",
    "latitude" => "42.1445185",
    "locId" => "L5003595",
    "location_name" => "Beartown Road, Pond",
    "longitude" => "-77.1706778",
    "subnational1" => "US-NY",
    "subnational2" => "US-NY-101"
  }, 'eBird::Hotspot' ),
