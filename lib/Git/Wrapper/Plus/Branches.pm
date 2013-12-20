use strict;
use warnings;

package Git::Wrapper::Plus::Branches;

# ABSTRACT: Extract branches from Git

=head1 SYNOPSIS

This module aims to do what you want when you think you want to parse the output of

    git branch

Except it works the right way, and uses

    git for-each-ref

So

    use Dist::Zilla::Util::Git::Branches;

    my $branches = Dist::Zilla::Util::Git::Branches->new(
        zilla => $self->zilla
    );
    for my $branch ( $branches->branches ) {
        printf "%s %s", $branch->name, $branch->sha1;
    }

=cut

use Moo;
use Scalar::Util qw(blessed);
use Try::Tiny qw( try catch );

has 'git' => ( is => ro =>, required => 1 );
has 'refs' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_refs {
  my ($self) = @_;
  require Git::Wrapper::Plus::Refs;
  return Git::Wrapper::Plus::Refs->new( git => $self->git );
}

sub _build_versions {
  my ($self) = @_;
  require Git::Wrapper::Plus::Versions;
  return Git::Wrapper::Plus::Versions->new( git => $self->git );
}

sub _to_branch {
  my ( $self, $ref ) = @_;
  require Git::Wrapper::Plus::Branch;
  return Git::Wrapper::Plus::Branch->new_from_Ref($ref);
}

sub _to_branches {
  my ( $self, @refs ) = @_;
  return map { $self->_to_branch($_) } @refs;
}

=method C<branches>

Returns a C<::Branch> object for each local branch.

=cut

sub branches {
  my ( $self, ) = @_;
  return $self->get_branch(q[**]);
}

=method get_branch

Get branch info about master

    my $branch = $branches->get_branch('master');

Note: This can easily return multiple values.

For instance, C<branches> is implemented as

    my ( @branches ) = $branches->get_branch('**');

Mostly, because the underlying mechanism is implemented in terms of L<< C<fnmatch(3)>|fnmatch(3) >>

If the branch does not exist, or no branches match the expression, C<< get_branch >>  will return an empty list.

So in the top example, C<$branch> is C<undef> if C<master> does not exist.

=cut

sub get_branch {
  my ( $self, $name ) = @_;
  return $self->_to_branches( $self->refs->get_ref( 'refs/heads/' . $name ) );
}

sub _current_sha1 {
  my ($self)          = @_;
  my (@current_sha1s) = $self->git->rev_parse('HEAD');
  if ( scalar @current_sha1s != 1 ) {
    require Carp;
    Carp::confess('Fatal: rev_parse HEAD returned != 1 values');
  }
  return shift @current_sha1s;
}

sub _current_branch_name {
  my ($self) = @_;
  my (@current_names);
  my $ok;
  try {
    (@current_names) = $self->git->symbolic_ref('HEAD');
    $ok = 1;
  }
  catch {
    my $e = $_;
    if ( not ref $e ) {
      die $e;
    }
    if ( not blessed $e ) {
      die $e;
    }
    if ( not $e->isa('Git::Wrapper::Exception') ) {
      die $e;
    }
    if ( $e->status == 128 ) {
      undef $ok;
      return;
    }
    die $e;
  };
  if ($ok) {
    return map { $_ =~ s{\A refs/heads/ }{}msx; $_ } @current_names;
  }
  return;

}

=method C<current_branch>

Returns a C<::Branch> object if currently on a C<branch>, C<undef> otherwise.

    my $b = $branches->current_branch;
    if ( defined $b ) {
        printf "Currently on: %s", $b->name;
    } else {
        print "Detached HEAD";
    }

=cut

sub current_branch {
  my ( $self, ) = @_;
  my ($ref) = $self->_current_branch_name;
  return if not $ref;
  return if $ref eq 'HEAD';    # Weird special case.
  my (@items) = $self->get_branch($ref);
  return shift @items if @items == 1;
  require Carp;
  Carp::confess( 'get_branch(' . $ref . ') returned multiple values. Cannot determine current branch' );
}

no Moo;

1;
