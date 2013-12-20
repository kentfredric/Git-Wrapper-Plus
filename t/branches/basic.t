
use strict;
use warnings;

use Test::More;

use Path::Tiny qw(path);

my $tempdir = Path::Tiny->tempdir;
my $repo    = $tempdir->child('git-repo');
my $home    = $tempdir->child('homedir');

local $ENV{HOME}                = $home->absolute->stringify;
local $ENV{GIT_AUTHOR_NAME}     = 'A. U. Thor';
local $ENV{GIT_AUTHOR_EMAIL}    = 'author@example.org';
local $ENV{GIT_COMMITTER_NAME}  = 'A. U. Thor';
local $ENV{GIT_COMMITTER_EMAIL} = 'author@example.org';

$repo->mkpath;
my $file = $repo->child('testfile');

use Git::Wrapper;
use Test::Fatal qw(exception);
use Sort::Versions;

my $wrapper = Git::Wrapper->new( $repo->absolute );

our ($IS_ONE_FIVE_PLUS);

if ( versioncmp( $wrapper->version, '1.5' ) > 0 ) {
  note "> 1.5";
  $IS_ONE_FIVE_PLUS = 1;
}

sub report_ctx {
  my (@lines) = @_;
  note explain \@lines;
}

my $excp = exception {
  if ($IS_ONE_FIVE_PLUS) {
    $wrapper->init();
  }
  else {
    $wrapper->init_db;
  }
  $file->touch;
  $wrapper->add( $file->relative($repo) );
  $wrapper->commit( '-m', 'Test Commit' );
  $wrapper->checkout( '-b', 'master_2' );
  $file->spew('New Content');
  if ($IS_ONE_FIVE_PLUS) {
    note 'git add ' . $file->relative($repo);
    $wrapper->add( $file->relative($repo) );
  }
  else {
    note 'git update-index ' . $file->relative($repo);
    $wrapper->update_index( $file->relative($repo) );
  }
  $wrapper->commit( '-m', 'Test Commit 2' );
  $wrapper->checkout( '-b', 'master_3' );

  my ( $tip, ) = $wrapper->rev_parse('HEAD');
};
is( $excp, undef, 'Git::Wrapper methods executed without failure' );

use Git::Wrapper::Plus::Branches;
my $branch_finder = Git::Wrapper::Plus::Branches->new( git => $wrapper );

is( $branch_finder->current_branch->name, 'master_3', 'master_3 exists' );
is( scalar $branch_finder->branches,      3,          '3 Branches found' );
my $branches = {};
for my $branch ( $branch_finder->branches ) {
  $branches->{ $branch->name } = $branch;
}
ok( exists $branches->{master},   'master branch found' );
ok( exists $branches->{master_2}, 'master_2 branch found' );
ok( exists $branches->{master_3}, 'master_3 branch found' );
is( $branches->{master_2}->sha1, $branches->{master_3}->sha1, 'master_2 and master_3 have the same sha1' );

done_testing;

