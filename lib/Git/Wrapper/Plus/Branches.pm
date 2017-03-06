use 5.006;    # our
use strict;
use warnings;

package Git::Wrapper::Plus::Branches;

our $VERSION = '0.004012';

# ABSTRACT: Extract branches from Git

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Git::Wrapper::Plus::Branches",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=head1 SYNOPSIS

This module aims to do what you want when you think you want to parse the output of

    git branch

Except it works the right way, and uses

    git for-each-ref

So

    use Git::Wrapper::Plus::Branches;

    my $branches = Git::Wrapper::Plus::Branches->new(
        git => $git_wrapper
    );
    # Show details of every local branch
    for my $branch ( $branches->branches ) {
        printf "%s %s", $branch->name, $branch->sha1;
    }
    # Show details of all branches starting with master
    for my $branch ( $branches->get_branch("master*") ) {
        printf "%s %s", $branch->name, $branch->sha1;
    }
    # Show details of current branch
    for my $branch ( $branches->current_branch ) {
        printf "%s %s", $branch->name, $branch->sha1;
    }

=cut

use Moo qw( has );
use Git::Wrapper::Plus::Util qw(exit_status_handler);

=attr C<git>

B<REQUIRED>: A C<Git::Wrapper> Compatible object.

=attr C<refs>

B<OPTIONAL>: A C<Git::Wrapper::Plus::Refs> Compatible object ( mostly for plumbing )

=cut

has 'git' => ( is => ro =>, required => 1 );
has 'refs' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_refs {
  my ($self) = @_;
  require Git::Wrapper::Plus::Refs;
  return Git::Wrapper::Plus::Refs->new( git => $self->git );
}

sub _to_branch {
  my ( undef, $ref ) = @_;
  require Git::Wrapper::Plus::Ref::Branch;
  return Git::Wrapper::Plus::Ref::Branch->new_from_Ref($ref);
}

sub _to_branches {
  my ( $self, @refs ) = @_;
  return map { $self->_to_branch($_) } @refs;
}

=method C<branches>

Returns a C<::Branch> object for each local branch.

    for my $branch ( $b->branches ) {
        $branch # isa Git::Wrapper::Plus::Branch
    }

=cut

sub branches {
  my ( $self, ) = @_;
  return $self->get_branch(q[**]);
}

=method get_branch

Get branch info about master

    my ($branch,) = $branches->get_branch('master');

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

sub _current_branch_name {
  my ($self) = @_;
  my (@current_names);
  return unless exit_status_handler(
    sub {
      (@current_names) = $self->git->symbolic_ref('HEAD');
    },
    {
      128 => sub { return },
    },
  );
  s{\A refs/heads/ }{}msx for @current_names;
  return @current_names;

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
  my (@items) = $self->get_branch($ref);
  return shift @items if 1 == @items;
  require Carp;
  Carp::confess( 'get_branch(' . $ref . ') returned multiple values. Cannot determine current branch' );
}

no Moo;

1;
