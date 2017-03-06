use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Ref;

our $VERSION = '0.004011';

# ABSTRACT: An Abstract REF node

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Git::Wrapper::Plus::Ref",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=head1 SYNOPSIS

    use Git::Wrapper::Plus::Ref;

    my $instance = Git::Wrapper::Plus::Ref->new(
        git => $git_wrapper,
        name => "refs/heads/foo"
    );
    $instance->refname # refs/heads/foo
    $instance->name    # refs/heads/foo
    $instance->sha1    # deadbeefbadf00da55c0ffee

=cut

use Moo qw( has );

=attr C<name>

B<REQUIRED>: The user friendly name for this C<ref>

=attr C<git>

B<REQUIRED>: A C<Git::Wrapper> compatible object for resolving C<sha1> internals.

=cut

has 'name' => ( is => ro =>, required => 1 );
has 'git'  => ( is => ro =>, required => 1 );

=method C<refname>

Return the fully qualified ref name for this object.

This exists so that L<< C<name>|/name >> can be made specialized in a subclass, for instance, a C<branch>
may have C<name> as C<master>, and C<refname> will be overloaded to return C<refs/heads/master>.


This is then used by the L<< C<sha1>|/sha1 >> method to resolve the C<ref> name to a C<sha1>

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

