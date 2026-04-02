use v5.38;
use utf8;
no feature qw(module_true);

package eBird::Command::config;
use parent qw(eBird::Command);

use namespace::autoclean;
use Mojo::Util qw(dumper);

use eBird::Config;

=encoding utf8

=head1 NAME

eBird::Command::config - deal with the ebird config

=head1 SYNOPSIS

Show the current settings:

	% ebird config show

=head1 DESCRIPTION

=head2 Actions

=over 4

=item * default_action()

Returns C<show>.

=cut

sub default_action { 'show' }

=item * description()

=cut

sub description ( $self ) {
	"Dealing with config file"
	}

=back

=head2 Actions

=over 4

=item * action_show()

=cut

sub action_show ( $self, @args ) {
	my $config = $self->ebird->config;

	no warnings;

	my $c = $self->cli->ebird->config;

	my $e = <<~"HERE";
		Environment:
			EBIRD_API_KEY:    $ENV{'EBIRD_API_KEY'}
			EBIRD_CACHE_DIR:  $ENV{'EBIRD_CACHE_DIR'}
			EBIRD_PASSWORD:   $ENV{'EBIRD_PASSWORD'}
			EBIRD_USERNAME:   $ENV{'EBIRD_USERNAME'}

		File: @{[ $c->path ]}

		Values:
			general:
				locale: @{[ $c->general->locale ]}

			api:
				api_key: @{[ $c->api->api_key ]}

			website:
				username: @{[ $c->website->username ]}
				password: @{[ $c->website->password ]}
		HERE

	$self->cli->io->output($e);
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

__END__
