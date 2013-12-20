use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Tester;

# ABSTRACT: Utility for testing things with a git repository

use Moo;
use Path::Tiny qw(path);

has temp_dir => is => ro =>, lazy => 1, builder => 1;
has home_dir => is => ro =>, lazy => 1, builder => 1;
has repo_dir => is => ro =>, lazy => 1, builder => 1;
has git      => is => ro =>, lazy => 1, builder => 1;

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

sub run_env {
  my ( $self, $code ) = @_;
  local $ENV{HOME}                = $self->home_dir->absolute->stringify;
  local $ENV{GIT_AUTHOR_NAME}     = 'A. U. Thor';
  local $ENV{GIT_AUTHOR_EMAIL}    = 'author@example.org';
  local $ENV{GIT_COMMITTER_NAME}  = 'A. U. Thor';
  local $ENV{GIT_COMMITTER_EMAIL} = 'author@example.org';
  return $code->( $self, );
}

no Moo;
1;

