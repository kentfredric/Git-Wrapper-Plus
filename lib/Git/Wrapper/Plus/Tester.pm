use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Tester;

# ABSTRACT: Utility for testing things with a git repository

use Moo;
use Path::Tiny qw(path);

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Git::Wrapper::Plus::Tester",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=head1 DESCRIPTION

This module solves the problem of the tedious amount of leg work you need to do
to simply execute a test with Git.

Namely:

=over 4

=item * Creating a scratch directory

=item * Creating a fake home directory in that scratch directory

=item * Setting C<HOME> to that fake home

=item * Setting valid, but bogus values for C<GIT_(COMMITTER|AUTHOR)_(NAME|EMAIL)>

=item * Creating a directory for the repository to work with in the scratch directory

=item * Creating a Git::Wrapper instance with that repository path

=back

This module does all of the above for you, and makes some of them flexible via attributes.

=cut

=head1 SYNOPSIS

    use Git::Wrapper::Plus::Tester;

    my $t = Git::Wrapper::Plus::Tester->new();

    $t->run_env( sub {

        my $wrapper = $t->git;

        $wrapper->init_db(); # ETC.

    } );

=cut

=attr C<temp_dir>

B<OPTIONAL>

=attr C<home_dir>

B<OPTIONAL>

=attr C<repo_dir>

B<OPTIONAL>

=attr C<git>

B<OPTIONAL>

=cut

has temp_dir => is => ro =>, lazy => 1, builder => 1;
has home_dir => is => ro =>, lazy => 1, builder => 1;
has repo_dir => is => ro =>, lazy => 1, builder => 1;
has git      => is => ro =>, lazy => 1, builder => 1;

=attr C<committer_name>

B<OPTIONAL>. Defaults to C<A. U. Thor>

=attr C<committer_email>

B<OPTIONAL>. Defaults to C<author@example.org>

=attr C<author_name>

B<OPTIONAL>. Defaults to C<< ->committer_name >>

=attr C<author_email>

B<OPTIONAL>. Defaults to C<< ->committer_email >>

=cut

has committer_name  => is => ro =>, lazy => 1, builder => 1;
has committer_email => is => ro =>, lazy => 1, builder => 1;
has author_name     => is => ro =>, lazy => 1, builder => 1;
has author_email    => is => ro =>, lazy => 1, builder => 1;

sub _build_temp_dir {
  return Path::Tiny->tempdir;
}

sub _build_home_dir {
  my ( $self, @args ) = @_;
  my $d = $self->temp_dir->child('homedir');
  $d->mkpath;
  return $d;
}

sub _build_repo_dir {
  my ( $self, @args ) = @_;
  my $d = $self->temp_dir->child('repodir');
  $d->mkpath;
  return $d;
}

sub _build_git {
  my ( $self, @args ) = @_;
  require Git::Wrapper;
  return Git::Wrapper->new( $self->repo_dir->absolute->stringify );
}

sub _build_committer_name {
  return 'A. U. Thor';
}

sub _build_committer_email {
  return 'author@example.org';
}

sub _build_author_name {
  my ( $self, ) = @_;
  return $self->committer_name;
}

sub _build_author_email {
  my ( $self, ) = @_;
  return $self->committer_email;

}

=method C<run_env>

Sets up basic environment, and runs code, reverting environment when done.

    $o->run_env(sub {
        my $wrapper = $o->git;

    });

=cut

sub run_env {
  my ( $self, $code ) = @_;
  local $ENV{HOME}                = $self->home_dir->absolute->stringify;
  local $ENV{GIT_AUTHOR_NAME}     = $self->author_name;
  local $ENV{GIT_AUTHOR_EMAIL}    = $self->author_email;
  local $ENV{GIT_COMMITTER_NAME}  = $self->committer_name;
  local $ENV{GIT_COMMITTER_EMAIL} = $self->committer_email;
  return $code->( $self, );
}

no Moo;
1;

