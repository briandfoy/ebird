use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Taxonomy;
use Exporter qw(import);

use namespace::autoclean;
use eBird::Util qw(has_sqlite);

=encoding utf8

=head1 NAME

eBird::Taxonomy - tools that deal with birds collectively

=head1 SYNOPSIS

	use eBird::Taxonomy;

	my $object = eBird::Taxonomy->new( $ebird );

=head1 DESCRITION

=head2 Class Methods

=over 4

=item * new( EBIRD )


=cut

sub new ($class, $ebird = eBird->new( io => eBird::IO->new_quiet)) {
	state $self;
	return $self if defined $self;

	$self = bless { ebird => $ebird }, $class;

	# this is big, but we cache the results too, and this is a singleton
	$self->{'taxonomy'} = $ebird->taxonomy->taxa;

	$self->invert_taxonomy;
	}

=begin comment

{}
    "banding_codes" => "",
    "category" => "slash",
    "com_name_codes" => "WTGF LGFI LEGF",
    "common_name" => "Wedge-tailed/Lesser Grass-Finch",
    "extinct" => "",
    "extinct_year" => "",
    "family_com_name" => "Tanagers and Allies",
    "family_sci_name" => "Thraupidae",
    "order" => "Passeriformes",
    "report_as" => "",
    "sci_name_codes" => "EMHE EMYP",
    "scientific_name" => "Emberizoides herbicola/ypiranganus",
    "species_code" => "y00437",
    "taxon_order" => "35505.0"
  }, 'eBird::Data::Taxon' ),

  bless( {
    "banding_codes" => "",
    "category" => "spuh",
    "com_name_codes" => "",
    "common_name" => "passerine sp.",
    "extinct" => "",
    "extinct_year" => "",
    "family_com_name" => "",
    "family_sci_name" => "",
    "order" => "Passeriformes",
    "report_as" => "",
    "sci_name_codes" => "",
    "scientific_name" => "Passeriformes sp.",
    "species_code" => "passer1",
    "taxon_order" => "35852.0"
  }, 'eBird::Data::Taxon' ),

=end comment

=cut


=item * taxonomy_all_bands()

=cut

sub all_bands ( $self ) {
	state $cache_key = 'bands';

	my $data;

	# try the cache first
	$self->ebird->io->logger->debug( "all_bands: trying the cache for <$cache_key>" );
	if( $self->ebird->cache->exists($cache_key) ) {
		$self->ebird->io->logger->debug( "all_bands: loading cache for <$cache_key>" );
		$data = $self->ebird->cache->load($cache_key);
		$data = eval { decode_json($data) };
		return $data if defined $data;
		}

	$self->ebird->io->logger->debug( "all_bands: trying the database" );
	if( has_sqlite() ) {
		state $sth = $self-> >dbh->prepare
		}

	# get it from the taxonomy
	$self->ebird->io->logger->debug( "all_bands: trying the database" );
	unless( @bands ) {
		my $taxonomy = $self->ebird->taxonomy->taxa;
		foreach my $item ( $taxonomy->@* ) {
			next unless $item->banding_codes;
			$self->ebird->logger->debug( "all_bands: ")
			$results{$_} = $item for keys $item->{banding_codes}->%*;
			}


		}



	my %results;
	foreach my $item ( $taxonomy->@* ) {
		$results{$_} = $item for keys $item->{banding_codes}->%*;
		}

	return \%results;
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

