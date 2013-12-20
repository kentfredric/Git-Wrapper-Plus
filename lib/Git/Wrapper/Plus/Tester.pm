use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Tester;
BEGIN {
  $Git::Wrapper::Plus::Tester::AUTHORITY = 'cpan:KENTNL';
}
{
  $Git::Wrapper::Plus::Tester::VERSION = '0.001000';
}

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

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Wrapper::Plus::Tester - Utility for testing things with a git repository

=head1 VERSION

version 0.001000

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
