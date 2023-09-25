use v5.38;
no feature qw(module_true);

package eBird::Command::family;
use parent qw(eBird::Command);

use Mojo::Util qw(dumper);

use eBird::Util qw(:all);

=encoding utf8

=head1 NAME

eBird::Command::family - show taxonomic families

=head1 SYNOPSIS

	% ebird family
	Acanthisittidae     New Zealand Wrens
	Acanthizidae        Thornbills and Allies
	Accipitridae        Hawks, Eagles, and Kites
	...

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<show>.

=cut

sub default_action { 'list' }

=item * description

=cut

sub description ( $self ) {
	"Dealing with taxonomic families"
	}

=back

=head2 Actions

=over 4

=item * action_list

=cut

sub action_list ( $self, @args ) {
	my $data = $self->api->taxonomy;

	my %results;
	my $longest = -1;
	foreach my $item ( $data->@* ) {
		$results{$item->family_sci_name} //= $item->family_com_name;
		$longest = length $item->family_sci_name if length $item->family_sci_name > $longest;
		}

	foreach my $key ( sort keys %results ) {
		$self->cli->output( sprintf "%-*s  %s\n", $longest, $key, $results{$key} );
		}
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
