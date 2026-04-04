use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Observation;
use parent qw(eBird::Data::Base);

=encoding utf8

=head1 NAME

eBird::Data::Observation - the representation of a single species observation

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item * count

=cut

sub count ($self) { $self->howManyStr }

=item * date

=cut

sub date ($self) { $self->obsDt }

=item * id

=cut

sub id ($self) { $self->obsId }

=item * species_code

=cut

sub species_code ($self) { $self->speciesCode }

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
