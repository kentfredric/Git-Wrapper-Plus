use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Ref;

# ABSTRACT: An Abstract REF node

use Moo;

=attr C<name>

=attr C<git>

=cut

has name => is => ro =>, required => 1;
has git  => is => ro =>, required => 1;

=method C<refname>

Return the fully qualified ref name for this object.

=cut

sub refname {
  my ($self) = @_;
  return $self->name;
}

=method C<sha1>

Return the C<SHA1> resolving for C<refname>

=cut

sub sha1 {
  my ($self)    = @_;
  my ($refname) = $self->refname;
  my (@sha1s)   = $self->git->rev_parse($refname);
  if ( scalar @sha1s > 1 ) {
    require Carp;
    return Carp::confess( q[Fatal: rev-parse ] . $refname . q[ returned multiple values] );
  }
  return shift @sha1s;
}

no Moo;
1;

