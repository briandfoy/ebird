use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Command::website;
use parent qw(eBird::Command);
use builtin qw(ceil);

use namespace::autoclean;

=encoding utf8

=head1 NAME

eBird::Command::website - interact with the website

=head1 SYNOPSIS

	% ebird website checklists

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * default_action

Returns C<help>.

=cut

sub default_action { 'help' }

=item * description

=cut

sub description ( $self ) {
	"interact with the eBird website"
	}


=back

=head2 Actions

=over 4

=item * action_checklists

=cut

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

sub action_checklists ( $self, @args ) {
	@args = qw(list) unless @args;

	my $checklists = $self->cli->ebird->website->checklists_summary;
	if( ! defined $checklists or $checklists->@* == 0 ) {
		$self->ebird->io->output( "Could not extract checklists" );
		return $self->error_value;
		}

	my $places = ceil(log($checklists->@*) / log(10));

	my $template = '%*d   %10s   %10s   %9s   %s';

	$self->ebird->io->output( sprintf 'There are %d checklists', scalar $checklists->@* );

	my $count =  0;
	my $max   = 100;
	foreach my $c ( sort { $a->{'sequence'} <=> $b->{'sequence'} } $checklists->@* ) {
		last if $count >= $max;
		my $ymd = $c->{'datetime'} =~ s/T.*//r;
		my $cache_key = 'checklist-' . $c->{'checklist'};
		my $status = '';
		if( $self->ebird->cache->exists($cache_key) ) {
			$status = '(cached)';
			}
		elsif( $args[0] eq 'fetch' ) {
			sleep 30;
			$count++;
			my $data = $self->ebird->product->checklist($c->{'checklist'});
			$status = do {
				   if( ! defined $data )                           { '(failed)'  }
				elsif( ! $self->ebird->cache->exists($cache_key) ) { '(failed)'  }
				else                                               { '(fetched)' }
				};
			}

		$self->ebird->io->output(
			sprintf $template,
				$places, $c->{'sequence'},
				$ymd,
				$c->{'checklist'},
				$status,
				$c->{'location'},
			);
		}

	return $self->success_value;
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

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2026, brian d foy, All Rights Reserved.

You may use this code under the terms of the Artistic License 2.0.

The eBird API and its data have their own terms of use:
https://www.birds.cornell.edu/home/ebird-api-terms-of-use/

=cut

__PACKAGE__;

__DATA__

@@ help.txt

Output this help message:

	ebird website

	ebird website help

Fetch the checklist list from ebird.com (or the cache) and display it:

	ebird website checklists

Fetch the checklist from ebird.com (or the cache), and fetch any checklists
that are not already in the cache:

	ebird website checklists fetch

This only fetches 100 checklists at a timeat 30 second intervals to be nice to
the eBird website. That's about the number it tolerates downloading in one
session.
