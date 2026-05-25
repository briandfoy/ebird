use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Observation;
use parent qw(eBird::Data::Base);
use String::Sprintf;

=encoding utf8

=head1 NAME

eBird::Data::Observation - the representation of a single species observation

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item * checklist_id

=cut

sub checklist_id ($self) { $self->subId }

=item * count

=cut

sub count ($self) { $self->howManyStr }

=item * date

=cut

sub date ($self) { $self->obsDt }

=item * elevation

This is not part of the eBird observation data, but
=cut

sub elevation ($self) {
	return 0;
	unless( defined $self->{'geo'} ) {
		$self->{'geo'} = eBird::Data::Geo->new($self);
		}
	return unless $self->{'geo'};
	return $self->{'geo'}->elevation;
	}

=item * geo_coordinates

Returns the latitude, longitude, and elevation as a list

=cut

sub geo_coordinates ($self) {
	( $self->latitude, $self->longitude )
	}

=item * id

=cut

sub id ($self) { $self->obsId }

=item * latitude

=cut

sub latitude ($self) { $self->lat }

=item * location_id

=cut

sub location_id ($self) { $self->locId }

=item * location_name

=cut

sub location_name ($self) { $self->locName }

=item * longitude

=cut

sub longitude ($self) { $self->lng }

=item * scientific_name

=cut

sub scientific_name ($self) { $self->sciName }

=item * species_code

=cut

sub species_code ($self) { $self->speciesCode }

=item * taxon

Returns an L<eBird::Data::Taxon> object constructed from C<species_code>.

=cut

sub taxon ($self) {
	eBird::Data::Taxon->new_from_code( $self->species_code );
	}

=back

=head2 Queries

=over 4

=item * is_private

=cut

sub is_private ($self) { $self->locationPrivate ? 1 : 0 }

=item * is_valid

=cut

sub is_valid ($self) { $self->obsValid ? 1 : 0 }


=back

=head2 Instance methods

=over 4

=item * format( FORMAT )

Returns a string representing the object formatted according to the
sprintf-style C<FORMAT>. See L</Formatting>.

=cut

sub format ($self, $format) {
	state $formatter = $self->_make_formatter;
	my $line = eval { $formatter->sprintf( $format, $self ) };
	return $line;
	}

=back

=head2 KML

=over 4

=item * kml_placemark

=cut

sub kml_placemark ($self) {
	state $template = <<~'KML';
		<Placemark>
			<name><![CDATA[%s]]></name>
			<description><![CDATA[%s]]></description>
			<Point>
				<coordinates>%f,%f,%f</coordinates>
			</Point>
		</Placemark>
		KML

	my $description = "This is the description";

	my @args = (
		join( ' ', $self->date, $self->location_name ),
		$description,
		$self->longitude,
		$self->latitude,
		$self->elevation,
		);

	sprintf $template, @args;
	}

=back

=head2 Formatting

=cut

sub _make_formatter ($self) {
	state $rc = require String::Sprintf;
	no warnings qw(numeric);
	String::Sprintf->formatter(
		'c' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->checklist_id               },
		'd' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->date                       },
		'g' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, join ', ', $V->[0]->geo_coordinates },
		'k' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->kml_placemark              },
		'l' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->location_id                },
		'L' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->location_name              },
		'n' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->common_name                },
		'N' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->count                      },
		'p' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->is_private  ? '*' : ' '    },
		'r' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->is_reviewed ? '*' : ' '    },
		'S' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->scientific_name            },
		's' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->species_code               },
		't' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->taxon->taxon_order         },
		'v' => sub ($w, $v, $V, $l) { sprintf '%*s', $w, $V->[0]->is_valid ? '*' : ' ';      },
		);
	}

=over 4

=item * C<c> - Sub ID (checklist ID)

=item * C<d> - date

=item * C<g> - latitude,longitude

=item * C<l> - location name

=item * C<L> - location ID

=item * C<n> - common name

=item * C<N> - count

=item * C<p> - private (C<*> if true, or C< > (space) if false)

=item * C<r> - reviewed (C<*> if true, or C< > (space) if false)

=item * C<S> - scientific name

=item * C<s> - species code

=item * C<t> - taxon order

=item * C<v> - valid  (C<*> if true, or C< > (space) if false)

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
{
  "projId": "EBIRD",
  "subId": "S29893687",
  "protocolId": "P21",
  "locId": "L99381",
  "durationHrs": 1,
  "allObsReported": false,
  "creationDt": "2018-01-04 14:30",
  "lastEditedDt": "2018-01-09 18:45",
  "obsDt": "2018-01-04 23:29",
  "obsTimeValid": true,
  "checklistId": "CL22224",
  "numObservers": 1,
  "subnational1Code": "US-NY",
  "submissionMethodCode": "EBIRD_api",
  "userDisplayName": "Tim Lenz",
  "obs": [
    {
      "speciesCode": "gwfgoo",
      "hideFlags": [],
      "obsDt": "2018-01-04 18:29",
      "subnational1Code": "US-NY",
      "howManyAtleast": 1,
      "howManyAtmost": 1,
      "howManyStr": "1",
      "present": false,
      "projId": "EBIRD",
      "subId": "S29893687",
      "obsId": "OBS406047821"
    },
    {
      "speciesCode": "gwfgoo2",
      "hideFlags": [],
      "obsDt": "2018-01-04 18:29",
      "subnational1Code": "US-NY",
      "howManyAtleast": 1,
      "howManyAtmost": 1,
      "howManyStr": "1",
      "present": false,
      "projId": "EBIRD",
      "subId": "S29893687",
      "obsId": "OBS406047822"
    },
    {
      "speciesCode": "cacgoo1",
      "hideFlags": [],
      "obsDt": "2018-01-04 18:29",
      "subnational1Code": "US-NY",
      "howManyAtleast": 1,
      "howManyAtmost": 1,
      "howManyStr": "1",
      "present": false,
      "projId": "EBIRD",
      "subId": "S29893687",
      "obsId": "OBS406047820",
      "obsAux": [
        {
          "subId": "S29893687",
          "obsId": "OBS406047820",
          "speciesCode": "cacgoo1",
          "fieldName": "breeding_code",
          "entryMethodCode": "ebird_breeding",
          "auxCode": "UN",
          "value": "C4"
        }
      ]
    }
  ]
}
