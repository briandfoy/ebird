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
