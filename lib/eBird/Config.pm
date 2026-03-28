use v5.38;
no feature qw(module_true);

package eBird::Config;
use parent qw(Hash::AsObject);

use namespace::autoclean;
use Carp qw(carp);
use Mojo::File;
use String::Redactable;
use TOML qw(from_toml);

=encoding utf8

=head1 NAME

eBird::Config - manage the config file

=head1 SYNOPSIS

	use eBird::Cache;
	use eBird::Config;
	use File::Spec::Functions;

	my $cache = eBird::Cache->new;

	my $config = eBird::Config->new_from_file(
		catfile( $cache->dir, 'config.toml' )
		);

	my $user = $config->user;
	my $pass = $config->password;

=head1 DESCRIPTION

=head2 Class methods

=over 4

=item * new( FILE )

=cut

sub _check_file ($class, $file) {
	1

	# file exists

	# file is not available to others


	}

sub _guess_locale ($class) {
	my @guesses =  map { s/\..*//r } grep { defined $ENV{$_} } qw(LANG LC_ALL);
	push @guesses, 'en_US';

	return $guesses[0];
	}

sub new ( $class, $file = undef ) {
	state $defaults = {
		api => { api_key => $ENV{'EBIRD_API_KEY'} },
		website => {
			username => $ENV{'EBIRD_USERNAME'},
			password => $ENV{'EBIRD_PASSWORD'},
			},
		general => {
			locale => $class->_guess_locale,
			},
		};

	my $data = {};
	if( defined $file ) {
		$class->_check_file($file);

		my $toml = Mojo::File->new($file)->slurp;
		my($d, $err) = from_toml($toml);
		if( $err ) {
			carp "Error in config file <$file>: $err";
			return;
			}
		$data = $d;
		}

	foreach my $key ( keys $defaults->%* ) {
		$data->{$key} = { $defaults->{$key}->%*, $data->{$key}->%* }
		}

	$data->{'api'}{'api_key'} = String::Redactable->new( $data->{'api'}{'api_key'} )
		if eval { exists $data->{'api'}{'api_key'} };

	$data->{'website'}{'password'} = String::Redactable->new( $data->{'website'}{'password'} )
		if eval { exists $data->{'website'}{'password'} };


	bless {
		path => $file,
		$data->%*,
		}, $class;
	}

=back

=head2 Instance methods

=over 4

=item * path

Returns the path to the config file

=back

=head3 api config

Access these through the C<website> method:

	$config->api->api_key;

=over 4

=item * api_key

Returns a L<String::Redactable> version of the website password.

=cut

=back

=head3 general

Access these through the C<website> method:

	$config->general->locale;

=over 4

=item * locale

Returns the locale to use. The default is C<en>.

=back

=head3 website

Access these through the C<website> method:

	$config->website->password;

=over 4

=item * password

Returns a L<String::Redactable> version of the website password.

=item * username

Returns the website username

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
