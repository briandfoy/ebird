use v5.36;
use Test::More 1.0;
use lib qw(lib);

my $class = 'eBird::RegionType';
my @concrete_methods = qw(
	has_sub_region
	sub_region_type
	parent_region_type
	is_world
	is_country
	is_subnational1
	is_subnational2
	is_subnational2
	is_null
	is_type
	is_in_name
	);

=encoding utf8

=head1 NAME

t/region_type.t

=head1 SYNOPSIS

Run all the tests:

	make test

Run just this test:

	perl t/region_type.t

=head1 DESCRIPTION

=cut


subtest 'sanity' => sub {
	use_ok $class;
	};

subtest 'region types' => sub {
	my $method = 'region_types';
	can_ok $class, $method;
	my @types = $class->$method();
	is scalar @types, 6, q(the count of type is right);
	};

subtest 'new' => sub {
	my $method = 'new';
	can_ok $class, $method;

	my $warnings;
	local $SIG{'__WARN__'} = sub {
		$warnings .= $_[0];
		};

	subtest 'in abstract class' => sub {
		$warnings = '';
		my $obj = eval { $class->$method() };
		ok ! defined $obj, 'bad call does not get an object';
		like $@, qr/Can't call method "new" via package "eBird::RegionType"/, 'die message for abstract class is correct';
		};

	subtest 'in concrete classes' => sub {
		$warnings = '';
		foreach my $region ( $class->region_types ) {
			subtest $region => sub {
				my $subclass = join '::', $class, $region;
				my $obj = eval { $subclass->$method() };
				check_class( $obj, $class, $subclass, @concrete_methods );
				}
			};
		};
	};

subtest 'identity' => sub {
	state @id_methods = qw(
		has_subregions
		is_world
		is_country
		is_subnational1
		is_subnational2
		is_location
		is_null
		is_type
		is_in_name
		);
	foreach my $region ( $class->region_types ) {
		subtest $region => sub {
			my $subclass = join '::', $class, "\u\L$region";
			my $obj = eval { $subclass->new };
			check_class( $obj, $class, $subclass, @concrete_methods );

			subtest 'is itself' => sub {
				my $self_method = sprintf "is_\L$region";
				can_ok $obj, $self_method;
				ok $obj->$self_method;
				};

			subtest 'is not others' => sub {
				foreach my $not_region ( grep { $_ ne $region } $class->region_types ) {
					my $self_method = sprintf "is_\L$not_region";
					can_ok $obj, $self_method;
					ok ! $obj->$self_method, "object isn't a type for another";
					}
				};

			subtest "is type" => sub {
				my $method = 'is_type';
				my $answer = 1;
				$answer = 0 if $region =~ /Null/i;
				can_ok $obj, $method;
				is $obj->$method(), $answer, 'region is a type'
				};

			subtest "is in name" => sub {
				my $method = 'is_in_name';
				my $answer = 1;
				$answer = 0 if $region =~ /World|Null/i;
				can_ok $obj, $method;
				is $obj->$method(), $answer, 'region is the name'
				};

			subtest "has subregions" => sub {
				my $method = 'has_sub_region';
				my $answer = 1;
				$answer = 0 if $region =~ /Null|Location/i;
				can_ok $obj, $method;
				is $obj->$method(), $answer, 'region has subregions'
				};
			};
		}
	};


sub check_class ($obj, $class, $subclass, @methods) {
	isa_ok $obj, $class;
	isa_ok $obj, $subclass;
	can_ok $obj, @methods;
	}


done_testing();

=back

=head1 TO DO

=head1 SEE ALSO

=over 4

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
