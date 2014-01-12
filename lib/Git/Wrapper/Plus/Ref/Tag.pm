use 5.008;    # utf8
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

use Moo qw( extends );
extends 'Git::Wrapper::Plus::Ref';

=head1 SYNOPSIS


    use Git::Wrapper::Plus::Ref::Tag;
    my $t = Git::Wrapper::Plus::Ref::Tag->new(
        git => $git,
        name => '1.2',
    );
    $t->name # '1.2'
    $t->refname # 'refs/tags/1.2'
    $t->verify # git tag -v 1.2
    $t->delete # git tag -d 1.2


=cut

=method C<new_from_Ref>

Convert a Plus::Ref to a Plus::Ref::Tag

    my $tag = $class->new_from_Ref( $ref );

=cut

sub new_from_Ref {
  my ( $class, $source_object ) = @_;
  if ( not $source_object->can('name') ) {
    require Carp;
    return Carp::croak("Object $source_object does not respond to ->name, cannot Ref -> Tag");
  }
  my $name = $source_object->name;
  ## no critic ( Compatibility::PerlMinimumVersionAndWhy )
  if ( $name =~ qr{\Arefs/tags/(.+\z)}msx ) {
    return $class->new(
      git  => $source_object->git,
      name => $1,
    );
  }
  require Carp;
  Carp::croak("Path $name is not in refs/tags/*, cannot convert to Tag object");
}

=attr C<name>

=attr C<git>

=method C<refname>

Returns C<name>, in the form C<< refs/tags/B<< <name> >> >>

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

