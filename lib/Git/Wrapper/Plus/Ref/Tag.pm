use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Ref::Tag;

# ABSTRACT: A single tag object

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Git::Wrapper::Plus::Ref::Tag",
    "interface":"class",
    "inherits":"Git::Wrapper::Plus::Ref"
}

=end MetaPOD::JSON

=cut

use Moo;
extends 'Git::Wrapper::Plus::Ref';

=method C<new_from_Ref>

Convert a Plus::Ref to a Plus::Ref::Tag

    my $tag = $class->new_from_Ref( $ref );

=cut

sub new_from_Ref {
  my ( $class, $object ) = @_;
  if ( not $object->can('name') ) {
    require Carp;
    return Carp::croak("Object $object does not respond to ->name, cannot Ref -> Tag");
  }
  my $name = $object->name;
  if ( $name =~ qr{\Arefs/tags/(.+\z)}msx ) {
    return $class->new(
      git  => $object->git,
      name => $1,
    );
  }
  require Carp;
  Carp::croak("Path $name is not in refs/tags/*, cannot convert to Tag object");
}

=attr C<name>

=attr C<git>

=cut

sub refname {
  my ($self) = @_;
  return 'refs/tags/' . $self->name;
}

=method C<verify>

=cut

sub verify {
  my ( $self, ) = @_;
  return $self->git->tag( '-v', $self->name );
}

=method C<delete>

=cut

## no critic (ProhibitBuiltinHomonyms)

sub delete {
  my ( $self, ) = @_;
  return $self->git->tag( '-d', $self->name );
}

no Moo;
1;

