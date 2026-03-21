use v5.36;
use utf8;

package eBird::RegionType;

use namespace::autoclean;
use Carp qw(croak);

=encoding utf8

=head1 NAME

eBird::RegionType - define identity of the region types and their relationships

=head1 SYNOPSIS

Most of this is for internal use to construct and validate regions.

=head1 DESCRIPTION

The eBird API defines several types of regions as divisions of larger
regions. The visible parts include the Country, Subnational1 (typcially
states or provinces), and Subnational2 (metropolations, cities, etc),
although not all Subnational1 divisions are further divided.

The Subnational1 region is typically a string, such as C<NY> for New
York. The Subnational2, if defined, is typically a three digit number,
such as C<001> for the Albany area.

A region string in eBird, used in various parts of the API, take the
defined parts and joins them with a dash, C<->, to form the region
string. For the United States, New York, you have C<US-NY>. For the
Albany area, you have C<US-NY-001>.

=head2 Methods

=over 4

=item * has_parent_region

Returns true for the region types that are a smaller division of a larger region
type.

=item * has_sub_region

Returns true for the region types that have smaller divisions.

=cut

sub has_parent_region ($self) { 0 + ! $self->parent_region_type->is_null }
sub has_sub_region    ($self) { 0 + ! $self->sub_region_type->is_null }

=item * is_country

Return false, except in L<eBird::RegionType::Country> which overrides it to be true.

=item * is_in_name

Return true, except in L<eBird::RegionType::> which overrides it to be true.

=item * is_null

Return false, except in L<eBird::RegionType::Null> which overrides it to be true.

=item * is_subnational1

Return false, except in L<eBird::RegionType::Subnational1> which overrides it to be true.

=item * is_subnational2

Return false, except in L<eBird::RegionType::Subnational2> which overrides it to be true.

=item * is_type

Returns true except in L<eBird::RegionType::Null> and L<eBird::RegionType::World>,
which are virtual types.

=item * is_world

Return false, except in L<eBird::RegionType::World> which overrides it to be true.

=cut

sub is_country        { 0 }
sub is_in_name        { 1 }
sub is_null           { 0 }
sub is_subnational1   { 0 }
sub is_subnational2   { 0 }
sub is_type           { 1 }
sub is_world          { 0 }

=item * parent_region_type

Returns the type for the larger division. In this class, that is L<eBird::RegionType::Null>,
and each concrete class overrides this if they are part of a larger division.

=item * sub_region_type

Returns the type for the smaller division. In this class, that is L<eBird::RegionType::Null>,
and each concrete class overrides this if they comprise smaller divisions.

=cut

sub parent_region_type ($self) { 'eBird::RegionType::Null' };
sub sub_region_type    ($self) { 'eBird::RegionType::Null' };


=head2

=over 4

=item * new()

This is a constructor that is inherited by the concrete classes but will croak
in this class. This creates flyweight singletons. There are no arguments.

=cut

sub new ($class)     {
	state $known = {};
	croak sprintf qq(Can't call method "new" via package "%s". This is only available in concrete types."), __PACKAGE__
		if $class eq __PACKAGE__;
	return $known->{$class} //= bless {}, $class;
	}

=back

=pod

There is a set of convenience methods that you can call from this module,
although these are not inherited by any of its subclasses.

=over

=item * new_country_type

Returns L<eBird::RegionType::Country>.

=item * new_null_type

Returns L<eBird::RegionType::Null>.

=item * new_subnational1_type

Returns L<eBird::RegionType::Subnational1>.

=item * new_subnational2_type

Returns L<eBird::RegionType::Subnational2>.

=item * new_world_type

Returns L<eBird::RegionType::World>.

=cut

sub new_country_type      ($class) { $class->_new_type('Country')      }
sub new_null_type         ($class) { $class->_new_type('Null')         }
sub new_subnational1_type ($class) { $class->_new_type('Subnational1') }
sub new_subnational2_type ($class) { $class->_new_type('Subnational2') }
sub new_world_type        ($class) { $class->_new_type('World')        }

BEGIN {
	sub region_types { return qw(World Country Subnational1 Subnational2 Null) }
	foreach my $r ( __PACKAGE__->region_types ) {
		my $class = join '::', __PACKAGE__, $r;
		eval "require $class";
		}
	}

sub _new_type ( $class, $type_class ) {
	my $calling_method = (caller(1))[3];
	croak qq(Can't call method "$calling_method" via package "$class". This is only available in ) . __PACKAGE__
		unless $class eq __PACKAGE__;
	$type_class = join '::', __PACKAGE__, $type_class unless $type_class =~ /::/;
	$type_class->new;
	}

=back

__PACKAGE__;
