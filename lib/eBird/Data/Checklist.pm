use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Data::Checklist;
use parent qw(eBird::Data::Base);

=encoding utf8

=head1 NAME

eBird::Data::Checklist - the representation of a checklist through the API

=head1 SYNOPSIS


=head1 DESCRIPTION


=over 4

=item * checklist_id

=cut

sub checklist_id ($self) { $self->subId }

=item * creation_date

=cut

sub creation_date ($self) { $self->creationDt }

=item * duration

=cut

sub duration ($self) { $self->durationHrs }

=item * last_edited_date

=cut

sub last_edited_date ($self) { $self->lastEditedDt }

=item * location_id

=cut

sub location_id ($self) { $self->locId }

=item * observation_date

=cut

sub observation_date ($self) { $self->obsDt }

=item * observations

=cut

sub observations ($self) { $self->obs }

=item * observer_count

=cut

sub observer_count ($self) { $self->numObservers }

=item * reported_all_observations

=cut

sub reported_all_observations ($self) { $self->allObsReported }

=item * project_id

=cut

sub project_id ($self) { $self->projId }

=item * protocol_id

=cut

sub protocol_id ($self) { $self->protocolId }

=item * subnational1

=cut

sub subnational1 ($self) { $self->subnational1Code }

=item * user_display_name

=cut

sub user_display_name ($self) { $self->userDisplayName }

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
