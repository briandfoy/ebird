use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Endpoint::Product;
use parent qw(eBird::Endpoint::Base);

use eBird::Data::Taxon;

=encoding utf8

eBird::Endpoint::Product -

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item * top_100_contributors( REGION, DATE )

=cut

=begin comment

rankedBy      spp, cl     spp     Order by number of complete checklists (cl) or by number of species seen (spp).
maxResults    1 - 100     (all)   Only fetch this number of contributors.

=end comment

=cut

sub top_100_contributors ( $self, $region, $date, $query = {} ) {
	my( $year, $month, $day ) = $date =~ m/\A(\d{4})(\d{2})(\d{2})\z/a;

	my $data = $self->ebird->get(
		args => {
			regionCode => $region->code,
			'y' => $year,
			'm' => $month,
			'd' => $day,
			},
		bless_into    => 'eBird::Data::Base',
		cache_key     => "top100-$region-$date",
		path_template => 'product/top100/{{regionCode}}/{{y}}/{{m}}/{{d}',
		);

	[ map { bless $_, 'eBird::Contributor::Stat'; } $data->@* ];
	}


=item * recent_checklists( REGION )

=cut

=begin comment

maxResults	1 - 200	10	Only fetch this number of checklists.

=end comment

=cut

sub recent_checklists ( $self, $region, $query = {} ) {
	my $data = $self->ebird->get(
		args => {
			regionCode => $region->code,
			},
		bless_into    => 'eBird::Data::Checklist',
		cache_key     => "recent_checklists-$region",
		path_template => 'product/lists/{{regionCode}}',
		);
	}

=item * checklists_on_date( REGION, DATE )

=cut

=begin comment

sortKey	obs_dt, creation_dt	obs_dt	Order the results by the date of the checklist or by the date it was submitted. maxResults	1 - 200	10	Only fetch this number of checklists.

=end comment

=cut

sub checklists_on_date ( $self, $region, $date, $query = {} ) {
	my $data = $self->ebird->get(
		args => {
			regionCode => $region->code,
			},
		bless_into    => 'eBird::Data::Checklist',
		cache_key     => "checklists-$region-$date",
		path_template => 'product/lists/{{regionCode}}/{{y}}/{{m}}/{{d}}',
		query         => $query,
		);
	}

=item * regional_stats_on_date( REGION, DATE )


=cut

=begin comment

sortKey     obs_dt,creation_dt	obs_dt   Order the results by the date of the checklist or by the date it was submitted.
maxResults  1 - 200	            10       Only fetch this number of checklists.

=end comment

=cut

sub regional_stats_on_date ( $self, $region, $date, $query = {} ) {
	my $data = $self->ebird->get(
		args => {
			regionCode => $region,
			},
		bless_into    => 'eBird::Data::Stats',
		cache_key     => "checklists-$region-$date",
		path_template => 'product/lists/{{regionCode}}/{{y}}/{{m}}/{{d}}',
		query         => $query,
		);
	}

=item * species_in_region( REGION )


=cut

sub species_in_region ( $self, $region ) {
	my $data = $self->ebird->get(
		args => {
			regionCode => $region->code,
			},
		cache_key     => "species-list-" . $region->code,
		callback      => sub ($item) { eBird::Data::Taxon->new_from_code($item) },
		path_template => 'product/spplist/{{regionCode}}',
		);
	}

=item * view_checklist( CHECKLIST_ID )

=cut

sub view_checklist ( $self, $checklist_id ) {
	my $data = $self->ebird->get(
		args => {
			subId => $checklist_id,
			},
		bless_into    => 'eBird::Data::Checklist',
		cache_key     => "checklist-$checklist_id",
		path_template => 'product/checklist/view/{{subId}}',
		);
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
