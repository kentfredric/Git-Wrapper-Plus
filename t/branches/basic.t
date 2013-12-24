
use strict;
use warnings;

use Test::More;
use Git::Wrapper::Plus::Tester;
use Test::Fatal qw(exception);
use Git::Wrapper::Plus::Versions;
use Git::Wrapper::Plus::Branches;

my $t = Git::Wrapper::Plus::Tester->new();
my $v = Git::Wrapper::Plus::Versions->new( git => $t->git );

my $file  = $t->repo_dir->child('testfile');
my $rfile = $file->relative( $t->repo_dir )->stringify;
my $tip;

$t->run_env(
  sub {
    my $wrapper = $t->git;
    my $excp    = exception {
      if ( $v->newer_than('1.5') ) {
        $wrapper->init();
      }
      else {
        $wrapper->init_db();
      }

      $file->touch;
      $wrapper->add($rfile);
      $wrapper->commit( '-m', 'Test Commit' );
      $wrapper->checkout( '-b', 'master_2' );
      $file->spew('New Content');
      if ( $v->newer_than('1.5') ) {
        note 'git add ' . $rfile;
        $wrapper->add($rfile);
      }
      else {
        note 'git update-index ' . $rfile;
        $wrapper->update_index($rfile);
      }
      $wrapper->commit( '-m', 'Test Commit 2' );
      $wrapper->checkout( '-b', 'master_3' );

      ( $tip, ) = $wrapper->rev_parse('HEAD');
    };

    is( $excp, undef, 'Git::Wrapper methods executed without failure' ) or diag $excp;

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
    if ( $v->newer_than('1.5') ) {
        subtest 'Detached head test' => sub {
            $wrapper->checkout('master_3^');
            $excp = exception {
                is( $branch_finder->current_branch, undef, 'not currently on a branch');
            };
            is( $excp, undef, 'Didnt fail due to not being on a branch') or diag $excp;
        };
    }
  }

);
done_testing;

