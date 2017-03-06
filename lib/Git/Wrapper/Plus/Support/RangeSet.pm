use 5.006;    # our
use strict;
use warnings;

package Git::Wrapper::Plus::Support::RangeSet;

our $VERSION = '0.004012';

# ABSTRACT: A set of ranges of supported things

# AUTHORITY

use Moo qw( has );

=attr C<items>

The series of L<< C<::Range>|Git::Wrapper::Plus::Support::Range >> objects that comprise the set.

=cut

has 'items' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_items {
  return [];
}

=method C<add_range_object>

Appends C<$object> to the C<items> stash.

    $set->add_range_object( $object );

=cut

sub add_range_object {
  my ( $self, $range_object ) = @_;
  push @{ $self->items }, $range_object;
  return $self;
}

=method C<add_range>

    $set->add_range( %params );

This is essentially shorthand for

    require Git::Wrapper::Plus::Support::Range;
    $set->add_range_object( Git::Wrapper::Plus::Support::Range->new( %params ) );

See L<< C<::Support::Range>|Git::Wrapper::Plus::Support::Range >> for details.

=cut

sub add_range {
  my ( $self, @args ) = @_;
  my $config;
  if ( 1 == @args ) {
    $config = $args[0];
  }
  else {
    $config = {@args};
  }
  require Git::Wrapper::Plus::Support::Range;
  return $self->add_range_object( Git::Wrapper::Plus::Support::Range->new($config) );
}

=method C<supports_version>

    $set->supports_version( $gwp->versions );

Determines if the data based on C<items> indicate that a thing is supported on the C<git>
versions described by the C<Versions> object.

=cut

sub supports_version {
  my ( $self, $version_object ) = @_;
  for my $item ( @{ $self->items } ) {
    my $cmp = $item->supports_version($version_object);
    return $cmp if defined $cmp;
  }
  return;
}

no Moo;
1;

