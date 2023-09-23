#!/Users/brian/bin/perl
use v5.36;

use lib qw(/Users/brian/Dev/ebird/lib);
use eBird;
use Mojo::Util qw(dumper);

my $ebird = eBird->new( api_key => 'orah02cb8ml5' );
my $lat = '40.64';
my $long = '-73.94';

my @countries = $ebird->view_checklist( 'S147952661' );

say dumper( \@countries );

__END__
  blob:https://ebird.org/d89ee2e2-5a88-4acb-9277-926862f5be00


{"profileHandle":"MTE2NDY0","userDisplayName":"Kathleen Kirsch","numSpecies":35,"numCompleteChecklists":0,"rowNum":96,"userId":"USER116464"}


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
