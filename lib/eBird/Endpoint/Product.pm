use v5.38;
use utf8;
no feature qw(module_true);

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item *

=cut

sub top_100_contributors ( $self, $date, $country, $subnational1 = undef, $subnational2 = undef ) {
	state $path_template = 'product/top100/{{ region_code }}/{{ year }}/{{ month }}/{{ day }}';

	my( $year, $month, $day ) = $date =~ m/\A(\d{4})(\d{2})(\d{2})\z/a;

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "top100-$region-$date",
		args => {
			region_code => $region,
			year  => $year,
			month => $month,
			day   => $day,
			},
		);

	[ map { bless $_, 'eBird::Contributor::Stat'; } $data->@* ];
	}


=item * recent_checklists

=cut

sub recent_checklists ( $self, $country, $subnational1 = undef, $subnational2 = undef) {
	state $path_template = 'product/lists/{{ region }}';

	my $region = join( "-",
				grep { defined } ($country, $subnational1, $subnational2)
				);

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "recent_checklists-$region",
		args => {
			region => $region,
			},
		);
	}

=item * view_checklist( CHECKLIST_ID )

=cut

sub view_checklist ( $self, $checklist_id ) {
	state $path_template = 'product/checklist/view/{{ checklist_id }}';

	my $data = $self->get(
		path_template => $path_template,
		cache_key => "checklist-$checklist_id",
		args => {
			checklist_id => $checklist_id,
			},
		);

	my $object = eBird::Checklist->new( $data );
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
