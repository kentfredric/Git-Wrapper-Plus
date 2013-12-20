use strict;
use warnings;

package Git::Wrapper::Plus::Refs;

# ABSTRACT: Work with refs

use Moo;

has git => required => 1, is => ro =>;

=head1 SYNOPSIS

After doing lots of work with Git::Wrapper, I found there's quite a few ways to
work with refs, and those ways aren't exactly all equal, or supported on all versions of git.

This abstracts it so things can just use them.

    my $refs = Git::Wrapper::Plus::Refs->new( git => $git_wrapper );

    $refs->refs(); # A ::Ref object for each entry from `git ls-remote .`

    my ( @results ) = $refs->get_ref('refs/**'); # the same thing

    my ( @results ) = $refs->get_ref('refs/heads/**'); # all branches

    my ( @results ) = $refs->get_ref('refs/tags/**'); # all tags

    my ( @results ) = $refs->get_ref('refs/remotes/**'); # all remote branches

Note: You probably shouldn't use this module directly.

=cut

sub _for_each_ref {
  my ( $self, $refspec, $callback ) = @_;

  my $git_dir = $self->git->dir;
  for my $line ( $self->git->ls_remote( $git_dir, $refspec ) ) {
    if ( $line =~ qr{ \A ([^\t]+) \t ( .+ ) \z }msx ) {
      $callback->( $1, $2 );
      next;
    }
    require Carp;
    Carp::confess( 'Regexp failed to parse a line from `git ls-remote` :' . $line );
  }
  return;
}

=method C<refs>

Lists all C<refs> in the C<refs/> C<namespace>.

    my (@refs) = $reffer->refs();

Shorthand for

    my (@refs) = $reffer->get_ref('refs/**');

=cut

sub refs {
  my ($self) = @_;
  return $self->get_ref('refs/**');
}

=method C<get_ref>

Fetch a given C<ref>, or collection of C<ref>s, matching a specification.

    my ($ref) = $reffer->get_ref('refs/heads/master');
    my (@branches) = $reffer->get_ref('refs/heads/**');
    my (@tags)   = $reffer->get_ref('refs/tags/**');

Though reminder, if you're working with branches or tags, use the relevant modules =).

=cut

sub get_ref {
  my ( $self, $refspec ) = @_;
  my @out;
  $self->_for_each_ref(
    $refspec => sub {
      my ( $sha1, $refname ) = @_;
      push @out, $self->_mk_ref( $sha1, $refname );
    }
  );
  return @out;
}

sub _mk_ref {
  my ( $self, $sha1, $name ) = @_;
  require Git::Wrapper::Plus::Ref;
  return Git::Wrapper::Plus::Ref->new(
    git  => $self->git,
    name => $name,
  );
}
no Moo;

1;
