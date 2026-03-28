use v5.38;
use utf8;
no feature qw(module_true);

package eBird::SQLite;

use namespace::autoclean;
use DBI;
use DBD::SQLite;
use Exporter qw(import);
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);

=encoding utf8

=head1 NAME

eBird::SQLite -

=head1 SYNOPSIS


=head1 DESCRITION

=head2 Class Methods

=over 4

=item * new( FILE [,EBIRD] )

=cut

sub new ($class, $file, $ebird = eBird->new( io => eBird::IO->new_quiet ) ) {
 	state $rc = require DBI;

	my $path = catfile( $ebird->cache->dir, $file );
	unless( -e $ebird->cache->dir ) {
		make_path $ebird->cache->dir;
		}

    my $dbh = DBI->connect("dbi:SQLite:dbname=$path", '', '', { RaiseError => 1 });

    bless { dbh => $dbh, ebird => $ebird, path => $path }, $class;
	}

=back

=head2 Instance methods

=over

=item * dbh

=cut

sub dbh ($self) { $self->{'dbh'} }

=item * ebird

=cut

sub ebird ($self) { $self->{'ebird'} }

=item * init

=cut

sub init ($self, $locale = 'en', $version = '2025') {
	my $tables_sql = do { local $/; <DATA> };

	my @tables = split /;\s+/, $tables_sql;

	foreach my $table ( @tables ) {
		my $rv = $self->dbh->do($table);
		}

	$self->_load_locales;
	$self->_load_taxonomy_versions;

	$self->_load_taxa( $locale, $version );
	}

sub _load_locales ($self) {
	my $locales = $self->ebird->taxonomy->locale_codes;

	my $sth = $self->dbh->prepare(
		'INSERT INTO Locales (code, name, last_update) VALUES (?, ?, ?)'
		);

	foreach my $locale ($locales->@*) {
		$sth->execute( map { $locale->$_ } qw(code name last_update))
		}
	}

sub _load_taxa ($self, $locale = 'en', $version = '2025') {
	my $taxa = $self->ebird->taxonomy->taxa(
		locale  => $locale,
		version => $version,
		);

	my $sth = $self->dbh->prepare(
		'INSERT INTO Taxonomy VALUES (
			?, ?, ?, ?, ?,
			?, ?, ?, ?, ?,
			?, ?, ?, ?, ?,
			?
			)'
		);

	my $banding_sth = $self->dbh->prepare(
		'INSERT INTO BandingCodes VALUES ( ?, ? )'
		);


	my $scientific_names_sth = $self->dbh->prepare(
		'INSERT INTO ScientificNameCodes VALUES ( ?, ? )'
		);

	foreach my $taxon ($taxa->@*) {
		my $rc = $sth->execute(
			$locale,
			$version,
			map { $taxon->$_ } qw(
				scientific_name
				common_name
				species_code
				category
				taxon_order
				common_name_codes
				sci_name_codes
				banding_codes
				order
				family_common_name
				family_scientific_name
				report_as
				extinct
				extinct_year
				)
			);

		my @banding_codes = split /\s+/, $taxon->banding_codes;
		foreach my $code ( @banding_codes ) {
			$banding_sth->execute( $taxon->species_code, $code );
			}

		my @scientific_name_codes = $taxon->scientific_name_codes->@*;
		foreach my $code ( @scientific_name_codes ) {
			$scientific_names_sth->execute( $taxon->species_code, $code );
			}
		}
	}

sub _load_taxonomy_versions ($self) {
	my $versions = $self->ebird->taxonomy->versions;

	my $sth = $self->dbh->prepare(
		'INSERT INTO TaxonomyVersions VALUES ( ?, ? )'
		);

	foreach my $v ($versions->@*) {
		$sth->execute( $v->version, $v->is_latest ? 1 : 0 )
		}
	}

=item * path

=cut

sub path ($self) { $self->{'path'} }

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
CREATE TABLE IF NOT EXISTS Taxonomy (
	locale                 TEXT NOT NULL,
	version                TEXT NOT NULL,
	scientific_name        TEXT NOT NULL UNIQUE,
	common_name            TEXT NOT NULL UNIQUE,
	species_code           TEXT NOT NULL UNIQUE,
	category               TEXT NOT NULL CHECK ( category in ('domestic', 'form', 'hybrid', 'intergrade', 'issf', 'slash', 'species', 'spuh') ),
	taxon_order            TEXT NOT NULL,
	common_name_codes      TEXT NOT NULL,
	scientific_name_codes  TEXT NOT NULL,
	banding_codes          TEXT NOT NULL,
	"order"                TEXT NOT NULL,
	family_common_name     TEXT NOT NULL,
	family_scientific_name TEXT NOT NULL,
	report_as              TEXT,
	extinct                TEXT,
	extinct_year           TEXT,
	FOREIGN KEY (locale)  REFERENCES Locales(code)
	FOREIGN KEY (version) REFERENCES TaxonomyVersions(version)
	);

CREATE TABLE IF NOT EXISTS BandingCodes (
	species_code        TEXT NOT NULL,
	code                TEXT NOT NULL,
	FOREIGN KEY (species_code) REFERENCES Taxonomy(species_code)
	);

CREATE TABLE IF NOT EXISTS ScientificNameCodes (
	species_code     TEXT NOT NULL,
	code             TEXT NOT NULL,
	FOREIGN KEY (species_code) REFERENCES Taxonomy(species_code)
	);

CREATE TABLE IF NOT EXISTS Locales (
	code            TEXT NOT NULL UNIQUE,
	name            TEXT NOT NULL UNIQUE,
	last_update     TEXT
	);

CREATE TABLE IF NOT EXISTS TaxonomyVersions (
	version         TEXT NOT NULL UNIQUE,
	is_latest       INTEGER NOT NULL CHECK (is_latest IN (0, 1))
	);
